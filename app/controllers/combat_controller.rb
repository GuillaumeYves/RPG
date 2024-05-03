class CombatController < ApplicationController
    def initialize_combat_variables
        @result = nil
        @combat_logs = []
        @turn_count = 1
        @character.piety = false
        @opponent.piety = false if @opponent.is_a?(Character)
        @character.nullify = false
        @opponent.nullify = false if @opponent.is_a?(Character)
        @character.ephemeral_rebirth = false
        @opponent.ephemeral_rebirth = false if @opponent.is_a?(Character)
        @character.took_damage = false
        @opponent.took_damage = false if @opponent.is_a?(Character)
        @opponent_health_in_combat = @opponent.total_health.to_i
    end

    def reset_buffed_stats
        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats
    end

    def determine_opponent
        @character = current_user.selected_character
        @hunt = @character.accepted_hunt
        opponent_id = params[:opponent_id].to_i

        if Monster.exists?(opponent_id) && @hunt.present?
            @opponent = Monster.find(opponent_id)
        elsif Character.exists?(opponent_id) && opponent_id.to_i != current_user.selected_character.id
            @opponent = Character.find_by(id:opponent_id)
        end
    end

    def determine_combat_result
        @result =
            if @character.total_health.positive?
                '<strong style="font-size: 18px;">Victory</strong>'
            elsif @opponent_health_in_combat.positive?
                '<strong style="font-size: 18px;">Defeat</strong>'
            end
    end

    def combat_result
        combat_result = CombatResult.find(params[:combat_result_id])

        @opponent = combat_result.opponent
        @character = combat_result.character
        @combat_logs = combat_result.combat_logs
        @result = combat_result.result
        @opponent_health_in_combat = combat_result.opponent_health_in_combat
        @hunt = @character.accepted_hunt
    end

    def save_combat_result
        combat_result = CombatResult.create(
            character: current_user.selected_character,
            opponent: @opponent,
            combat_logs: @combat_logs,
            result: @result,
            opponent_health_in_combat: @opponent_health_in_combat
        )
        # Redirect to combat result page with combat result data
        redirect_to combat_result_character_path(combat_result_id: combat_result.id)

        @character.update_column(:total_health, @character.total_health)
        @hunt.update(combat_result: combat_result) if @hunt.present? && @result == '<strong style="font-size: 18px;">Victory</strong>'
    end

    def switch_turns
        @character_turn = !@character_turn
        @opponent_turn = !@opponent_turn
    end

    def combat_loop
        log_message =  "<span style='font-size: larger;'><strong>Turn #{@turn_count}</strong></span>"
            if @character_turn
                log_message += ": <span style='font-size: larger;'><strong>#{@character.character_name}</strong></span> "
            elsif @opponent_turn
                log_message += ": <span style='font-size: larger;'><strong>#{@opponent.character_name}</strong></span> " if @opponent.is_a?(Character)
                log_message += ": <span style='font-size: larger;'><strong>#{@opponent.monster_name}</strong></span> " if @opponent.is_a?(Monster)
            end
        @combat_logs << log_message

        while @character.total_health.positive? && @opponent_health_in_combat.positive?
            # Character's turn
            if @character_turn
                character_turn
            # Opponent's turn
            elsif @opponent_turn
                opponent_turn
            end

            switch_turns

            if @character.total_health.positive? && @opponent_health_in_combat.positive?
                @turn_count += 1
                log_message =  "<span style='font-size: larger;'><strong>Turn #{@turn_count}</strong></span>"
                if @character_turn
                    log_message += ": <span style='font-size: larger;'><strong>#{@character.character_name}</strong></span> "
                elsif @opponent_turn
                    log_message += ": <span style='font-size: larger;'><strong>#{@opponent.character_name}</strong></span> " if @opponent.is_a?(Character)
                    log_message += ": <span style='font-size: larger;'><strong>#{@opponent.monster_name}</strong></span> " if @opponent.is_a?(Monster)
                end
                @combat_logs << log_message
            end
            # Check if character or opponent is defeated
            break unless @character.total_health.positive? && @opponent_health_in_combat.positive?
        end

        # Determine combat result
        determine_combat_result

        log_message =  "#{@result}"
        @combat_logs << log_message

        # Default values for buffs at the end of the combat to prevent saving buffs
        reset_buffed_stats
    end

    def combat
        # Retrieve the player's character and determine the opponent
        @character = current_user.selected_character
        @opponent = determine_opponent

        # Check if the user has enough health to engage in combat
        if @character.total_health == 0
            flash[:alert] = "You do not have enough Health to engage in combat."
            redirect_back fallback_location: root_path
            return
        end

        # Randomly determine the first turn
        @character_turn = rand(2).zero?
        @opponent_turn = !@character_turn

        # Initialize combat
        initialize_combat_variables

        # Default values for buffs
        reset_buffed_stats

        # Combat has started, show a log
        log_message = '<strong style="font-size: 18px;">Battle has begun</strong>'
        @combat_logs << log_message

        combat_loop

        # Save the combat result
        save_combat_result
    end

    def physical_damage(total_attack, buffed_attack, total_armor, buffed_armor, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, total_global_damage, evasion, ignore_pain_chance)
        @is_miss = false
        @is_evade = false
        @is_crit = false
        @is_ignore_pain = false
        # Check for a miss with Forged in Battle
        if @character_turn && @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.0) <= 10.00
            damage = 0
            @is_miss = true
        elsif @opponent_turn && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            @is_miss = true
        else
            # Chance to evade damage
            if @character_turn && rand(0.00..100.00) <= evasion
                if @character.skills.find_by(name: 'Undeniable', unlocked: true).present?
                    damage = ((total_attack + buffed_attack) + ((total_attack + buffed_attack) * total_global_damage)) - (total_armor + buffed_armor)
                else
                    damage = 0
                    @is_evade = true
                end
            elsif @opponent_turn && rand(0.00..100.00) <= evasion
                if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Undeniable', unlocked: true).present?
                    damage = ((total_attack + buffed_attack) + ((total_attack + buffed_attack) * total_global_damage)) - (total_armor + buffed_armor)
                else
                    damage = 0
                    @is_evade = true
                end
            else
                # Check for a critical hit based on critical_strike_chance
                if rand(0.00..100.00) <= (total_critical_strike_chance + buffed_critical_strike_chance)
                    damage = (((total_attack + buffed_attack) + ((total_attack + buffed_attack) * total_global_damage)) * (total_critical_strike_damage + buffed_critical_strike_damage)) - (total_armor + buffed_armor)
                    @is_crit = true
                else
                    damage = ((total_attack + buffed_attack) + ((total_attack + buffed_attack) * total_global_damage)) - (total_armor + buffed_armor)
                    # Apply damage reduction based on ignore_pain_chance
                    if rand(0.00..100.00) <= ignore_pain_chance
                        damage *= 0.8  # Reduce incoming damage by 20%
                        @is_ignore_pain = true
                    end
                end
            end
        end

        damage.round
    end

    def magic_damage(total_spellpower, buffed_spellpower, total_magic_resistance, buffed_magic_resistance, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, total_global_damage, ignore_pain_chance)
        @is_miss = false
        @is_crit = false
        @is_ignore_pain = false
        # Check for a miss with Forged in Battle
        if @character_turn && @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            @is_miss = true
        elsif @opponent_turn && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            @is_miss = true
        else
            # Check for a critical hit based on critical_strike_chance
            if rand(0.00..100.00) <= (total_critical_strike_chance + buffed_critical_strike_chance)
                damage = (((total_spellpower + buffed_spellpower) + ((total_spellpower + buffed_spellpower) * total_global_damage)) * (total_critical_strike_damage + buffed_critical_strike_damage)) - (total_magic_resistance + buffed_magic_resistance)
                @is_crit = true
            else
                damage = ((total_spellpower + buffed_spellpower) + ((total_spellpower + buffed_spellpower) * total_global_damage)) - (total_magic_resistance + buffed_magic_resistance)
                # Apply damage reduction based on ignore_pain_chance
                if rand(0.00..100.00) <= ignore_pain_chance
                    damage *= 0.8  # Reduce incoming damage by 20%
                    @is_ignore_pain = true
                end
            end
        end

        damage.round
    end

    def shadow_damage(total_necrosurge, buffed_necrosurge, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, total_global_damage, evasion, ignore_pain_chance)
        @is_miss = false
        @is_evade = false
        @is_crit = false
        @is_ignore_pain = false
        # Check for a miss with Forged in Battle
        if @character_turn && @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            @is_miss = true
        elsif @opponent_turn && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            @is_miss = true
        else
            # Chance to evade damage
            if @character_turn && rand(0.00..100.00) <= evasion
                if @character.skills.find_by(name: 'Undeniable', unlocked: true).present?
                    damage = (((total_necrosurge + buffed_necrosurge) + ((total_necrosurge + buffed_necrosurge) * total_global_damage)) * (total_critical_strike_damage + buffed_critical_strike_damage))
                else
                    damage = 0
                    @is_evade = true
                end
            elsif @opponent_turn && rand(0.00..100.00) <= evasion
                if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Undeniable', unlocked: true).present?
                    damage = (((total_necrosurge + buffed_necrosurge) + ((total_necrosurge + buffed_necrosurge) * total_global_damage)) * (total_critical_strike_damage + buffed_critical_strike_damage))
                else
                    damage = 0
                    @is_evade = true
                end
            else
                # Check for a critical hit based on critical strike chance
                if rand(0.00..100.00) <= (total_critical_strike_chance + buffed_critical_strike_chance)
                    damage = (((total_necrosurge + buffed_necrosurge) + ((total_necrosurge + buffed_necrosurge) * total_global_damage)) * (total_critical_strike_damage + buffed_critical_strike_damage))
                    @is_crit = true
                else
                    damage = ((total_necrosurge + buffed_necrosurge) + ((total_necrosurge + buffed_necrosurge) * total_global_damage))
                    # Apply damage reduction based on ignore_pain_chance
                    if rand(0.00..100.00) <= ignore_pain_chance
                        damage *= 0.8  # Reduce incoming damage by 20%
                        @is_ignore_pain = true
                    end
                end
            end
        end

        damage.round
    end

    def character_turn
        # Initiate the variables
        damage = 0
        damage_type = ''

        # Apply the trigger skills
        if @character.took_damage == true
            @character.apply_trigger_skills
            if @character.skills.find_by(name: 'Surge of Light', unlocked: true).present?
                surge_of_light = (@character.total_max_health * 0.02).round
                @character.total_health += [surge_of_light, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name} recovered <strong>#{surge_of_light}</strong> Health with 'Surge of Light'"
                @combat_logs << log_message
                log_message = "#{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
                @combat_logs << log_message
            end
        end
        if @character.skills.find_by(name: 'Piety', unlocked: true).present? && (@character.total_health <= (@character.total_max_health * 0.5 )) && @character.piety == false
            piety = (@character.total_max_health * 0.20).round
            @character.total_health += [piety, @character.total_max_health - @character.total_health].min
            @character.piety = true
            log_message = "#{@character.character_name} recovered <strong>#{piety}</strong> Health with 'Piety' "
            @combat_logs << log_message
            log_message = "#{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
            @combat_logs << log_message
        end

            if @character.skills.find_by(name: 'Swift Movements', unlocked: true).present?
                # Picks the element of attack
                if @character.total_attack > @character.total_spellpower && @character.total_attack > @character.total_necrosurge
                    swift_movements = [physical_damage(@character.total_attack, @character.buffed_attack, @opponent.total_armor, @opponent.buffed_armor, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.evasion, @opponent.ignore_pain_chance) * 0.5, 0].max.round
                    damage_type = 'physical'
                elsif @character.total_spellpower > @character.total_attack && @character.total_spellpower > @character.total_necrosurge
                    swift_movements = [magic_damage(@character.total_spellpower, @character.buffed_spellpower, @opponent.total_magic_resistance, @opponent.buffed_magic_resistance, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.ignore_pain_chance) * 0.5, 0].max.round
                    damage_type = 'magic'
                elsif @character.total_necrosurge > @character.total_attack && @character.total_necrosurge > @character.total_spellpower
                    swift_movements = [shadow_damage(@character.total_necrosurge, @character.buffed_necrosurge, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.evasion, @opponent.ignore_pain_chance) * 0.5, 0].max.round
                    damage_type = 'shadow'
                end
                chance_of_additional_attack = @character.agility
                if rand(0.0..5000.0) <= chance_of_additional_attack
                    # Check for the statuses of an attack
                    if @is_miss == true
                        log_message = "MISS"
                        @combat_logs << log_message
                    elsif @is_evade == true
                        log_message = "EVADE"
                        @combat_logs << log_message
                    elsif @is_crit == true
                        log_message = "CRITICAL STRIKE"
                        @combat_logs << log_message
                        @opponent_health_in_combat -= swift_movements
                        log_message = "#{@character.character_name} attacked for <strong>#{swift_movements}</strong> #{damage_type} damage with 'Swift Movements'"
                    elsif @is_ignore_pain == true
                        log_message = "IGNORE PAIN"
                        @combat_logs << log_message
                        @opponent_health_in_combat -= swift_movements
                        log_message = "#{@character.character_name} attacked for <strong>#{swift_movements}</strong> #{damage_type} damage with 'Swift Movements'"
                    elsif @is_crit == true && is_ignore_pain == true
                        log_message = "CRITICAL STRIKE"
                        @combat_logs << log_message
                        log_message = "IGNORE PAIN"
                        @combat_logs << log_message
                        @opponent_health_in_combat -= swift_movements
                        log_message = "#{@character.character_name} attacked for <strong>#{swift_movements}</strong> #{damage_type} damage with 'Swift Movements'"
                    else
                        @opponent_health_in_combat -= swift_movements
                        log_message = "#{@character.character_name} attacked for <strong>#{swift_movements}</strong> #{damage_type} damage with 'Swift Movements'"
                    end
                    # Apply combat skills
                    @character.apply_combat_skills
                        # Proceed with diverse triggers after attacking
                        if rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                            sharpened_blade = ((@character.total_attack + @character.buffed_attack) * 0.5).round
                            @opponent_health_in_combat -= [(sharpened_blade - (@opponent.total_armor + @opponent.buffed_armor)), 0].max
                            log_message += ", <strong>#{sharpened_blade}</strong> physical damage with 'Sharpened Blade' "
                        elsif rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                            poisoned_blade = ((@character.total_attack + @character.buffed_attack) * 0.5).round
                            @opponent_health_in_combat -= [(poisoned_blade - (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance)), 0].max
                            log_message += ", <strong>#{poisoned_blade}</strong> magic damage with 'Poisoned Blade' "
                        end
                        if @is_crit == true && @character.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                            from_the_shadows = (damage * 0.25).round
                            @opponent_health_in_combat -= [from_the_shadows, 0].max
                            log_message += ", <strong>#{from_the_shadows}</strong> true damage with 'From the Shadows' "
                        end
                        if @character.skills.find_by(name: 'Skullsplitter', unlocked: true).present?
                            skullsplitter = (@opponent.total_max_health * 0.12).round
                            @opponent_health_in_combat -= [skullsplitter, 0].max
                            log_message += ", <strong>#{skullsplitter}</strong> additional true damage with 12 "
                        end
                        if @character.skills.find_by(name: 'Judgement', unlocked: true).present?
                            judgement = (damage * 0.05).round
                            @opponent_health_in_combat -= [judgement, 0].max
                            log_message += ", <strong>#{judgement}</strong> true damage with 'Judgement' "
                        end
                    @combat_logs << log_message
                end
                # After attack healing
                if @is_crit == true && @character.skills.find_by(name: 'Path of the Dead', unlocked: true).present? && damage.positive?
                    path_of_the_dead = (damage * 0.06).round
                    @character.total_health += [path_of_the_dead, @character.total_max_health - @character.total_health].min
                    log_message = "#{@character.character_name} recovered <strong>#{path_of_the_dead}</strong> Health with 'Path of the Dead'"
                    @combat_logs << log_message
                    log_message = " #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health}"
                    @combat_logs << log_message
                end
            end

        # Normal attack
        # Pick the element of attack
        if @character.total_attack > @character.total_spellpower && @character.total_attack > @character.total_necrosurge
            damage = [physical_damage(@character.total_attack, @character.buffed_attack, @opponent.total_armor, @opponent.buffed_armor, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.evasion, @opponent.ignore_pain_chance), 0].max
            damage_type = 'physical'
        elsif @character.total_spellpower > @character.total_attack && @character.total_spellpower > @character.total_necrosurge
            damage = [magic_damage(@character.total_spellpower, @character.buffed_spellpower, @opponent.total_magic_resistance, @opponent.buffed_magic_resistance, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.ignore_pain_chance), 0].max
            damage_type = 'magic'
        elsif @character.total_necrosurge > @character.total_attack && @character.total_necrosurge > @character.total_spellpower
            damage = [shadow_damage(@character.total_necrosurge, @character.buffed_necrosurge, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.evasion, @opponent.ignore_pain_chance), 0].max
            damage_type = 'shadow'
        end
        # Check for the statuses of an attack
        if @is_miss == true
            log_message = "MISS"
            @combat_logs << log_message

        elsif @is_evade == true
            log_message = "EVADE"
            @combat_logs << log_message

        elsif @is_crit == true
            log_message = "CRITICAL STRIKE"
            @combat_logs << log_message
            @opponent_health_in_combat -= [damage, 0].max
            log_message = "#{@character.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage"
        elsif @is_ignore_pain == true
            log_message = "IGNORE PAIN"
            @combat_logs << log_message
            @opponent_health_in_combat -= [damage, 0].max
            log_message = "#{@character.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage"
        elsif @is_crit == true && @is_ignore_pain == true
            log_message = "CRITICAL STRIKE"
            @combat_logs << log_message
            log_message = "IGNORE PAIN"
            @combat_logs << log_message
            @opponent_health_in_combat -= [damage, 0].max
            log_message = "#{@character.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage"
        else
            # Reduce opponent's health
            @opponent_health_in_combat -= [damage, 0].max
            log_message = "#{@character.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage"
        end
            # Apply combat skills
            @character.apply_combat_skills
                # Proceed with diverse triggers after attacking
                if rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                    sharpened_blade = ((@character.total_attack + @character.buffed_attack) * 0.5).round
                    @opponent_health_in_combat -= [(sharpened_blade - (@opponent.total_armor + @opponent.buffed_armor)), 0].max
                    log_message += ", <strong>#{sharpened_blade}</strong> physical damage with 'Sharpened Blade' "
                elsif rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                    poisoned_blade = ((@character.total_attack + @character.buffed_attack) * 0.5).round
                    @opponent_health_in_combat -= [(poisoned_blade - (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance)), 0].max
                    log_message += ", <strong>#{poisoned_blade}</strong> magic damage with 'Poisoned Blade' "
                end
                if @is_crit == true && @character.skills.find_by(name: 'From the Shadows', unlocked: true).present? && damage.positive?
                    from_the_shadows = (damage * 0.25).round
                    @opponent_health_in_combat -= [from_the_shadows, 0].max
                    log_message += ", <strong>#{from_the_shadows}</strong> true damage with 'From the Shadows' "
                end
                if @character.skills.find_by(name: 'Skullsplitter', unlocked: true).present? && damage.positive?
                    skullsplitter = (@opponent.total_max_health * 0.12).round
                    @opponent_health_in_combat -= [skullsplitter, 0].max
                    log_message += ", <strong>#{skullsplitter}</strong> additional true damage with 'Skullsplitter' "
                end
                if @character.skills.find_by(name: 'Judgement', unlocked: true).present? && damage.positive?
                    judgement = (damage * 0.05).round
                    @opponent_health_in_combat -= [judgement, 0].max
                    log_message += ", <strong>#{judgement}</strong> true damage with 'Judgement' "
                end
            @combat_logs << log_message

            # After attack healing
            if @is_crit == true && @character.skills.find_by(name: 'Path of the Dead', unlocked: true).present? && damage.positive?
                path_of_the_dead = (damage * 0.06).round
                @character.total_health += [path_of_the_dead, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name} recovered <strong>#{path_of_the_dead}</strong> Health with 'Path of the Dead'"
                @combat_logs << log_message
            end

            # Apply passive skills
            if @character.skills.find_by(name: 'Crimson Torrent', unlocked:true).present?
                crimson_torrent = (@character.total_max_health * 0.03).round
                @opponent_health_in_combat -= [crimson_torrent, 0].max
                log_message = "#{@character.character_name} dealt <strong>#{crimson_torrent}</strong> shadow damage with 'Crimson Torrent'"
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Deep Wounds', unlocked:true).present?
                deep_wounds = (@character.total_max_health * 0.08).round
                @character.total_max_health -= [(deep_wounds - (@character.total_armor + @character.buffed_armor)), 0].max
                log_message = "#{@opponent.character_name} dealt <strong>#{deep_wounds}</strong> physical damage with 'Deep Wounds'"
                @combat_logs << log_message
            end
            if @character.skills.find_by(name:'Lifetap', unlocked:true).present?
                lifetap = (@character.total_max_health * 0.01).round
                @character.total_health -= [lifetap, 0].max
                lifetap_buff = (lifetap * 2).round
                @character.buffed_necrosurge += lifetap_buff
                log_message = "#{@character.character_name} sacrificed <strong>#{lifetap}</strong> Health to gain <strong>#{lifetap_buff}</strong> Necrosurge with 'Lifetap'"
                @combat_logs << log_message
            end
            if @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth == true
                ephemeral_rebirth_damage = (@character.total_max_health * 0.10).round
                @character.total_health -= ephemeral_rebirth_damage
                log_message = "#{@character.character_name} lost <strong>#{ephemeral_rebirth_damage}</strong> Health with 'Ephemeral Rebirth'"
                @combat_logs << log_message
            end

            # Cheat death skills
            if @opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Nullify', unlocked: true).present? && @opponent.nullify == false
                @opponent_health_in_combat = 1
                @opponent.nullify = true
                log_message = "#{@opponent.character_name} has triggered 'Nullify'" if @opponent.nullify == true
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth  == false
                @opponent_health_in_combat = @opponent.total_max_health
                @opponent.ephemeral_rebirth = true
                log_message = "#{@opponent.character_name} has triggered 'Ephemeral Rebirth'" if @opponent.ephemeral_rebirth == true
                @combat_logs << log_message
            end

            # Log the Health after damage
            if @opponent.is_a?(Character)
                log_message = "#{@opponent.character_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
                @combat_logs << log_message
            elsif @opponent.is_a?(Monster)
                log_message = "#{@opponent.monster_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
                @combat_logs << log_message
            end

        # Ensure health doesn't go lower than 0
        @opponent_health_in_combat = [0, @opponent_health_in_combat].max
        # Opponent took damage is now true if damage is positive
        @opponent.took_damage = true if damage.positive?
        # Reset took damage to false
        @character.took_damage = false
    end

    def opponent_turn
        damage = 0
        damage_type = ''

        if @opponent.took_damage == true && @opponent.is_a?(Character)
            @opponent.apply_trigger_skills
            if @opponent.skills.find_by(name: 'Surge of Light', unlocked: true).present?
                surge_of_light = (@opponent.total_max_health * 0.02).round
                @opponent_health_in_combat += [surge_of_light, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name} recovered <strong>#{surge_of_light}</strong> Health with 'Surge of Light'"
                @combat_logs << log_message
            end
        end
        if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Piety', unlocked: true).present? && (@opponent_health_in_combat <= (@opponent.total_max_health* 0.50 )) && @opponent.piety == false
            piety = (@opponent.total_max_health * 0.20).round
            @opponent_health_in_combat += [piety, @opponent.total_max_health - @opponent_health_in_combat].min
            @opponent.piety = true
            log_message = "#{@opponent.character_name} recovered <strong>#{piety}</strong> Health with 'Piety'"
            @combat_logs << log_message
        end

        if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Swift Movements', unlocked: true).present?
            # Pick the element of attack
            if @opponent.total_attack > @opponent.total_spellpower && @opponent.total_attack > @opponent.total_necrosurge
                swift_movements = [physical_damage(@opponent.total_attack, @opponent.buffed_attack, @character.total_armor, @character.buffed_armor, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.evasion, @character.ignore_pain_chance) * 0.5, 0].max.round
                damage_type = 'physical'
            elsif @opponent.total_spellpower > @opponent.total_attack  && @opponent.total_spellpower > @opponent.total_necrosurge
                swift_movements = [magic_damage(@opponent.total_spellpower, @opponent.buffed_spellpower, @character.total_magic_resistance, @character.buffed_magic_resistance, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.ignore_pain_chance) * 0.5, 0].max.round
                damage_type = 'magic'
            elsif @opponent.total_necrosurge > @opponent.total_attack && @opponent.total_necrosurge > @opponent.total_spellpower
                swift_movements = [shadow_damage(@opponent.total_necrosurge, @opponent.buffed_necrosurge, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.evasion, @character.ignore_pain_chance) * 0.5, 0].max.round
                damage_type = 'shadow'
            end
            chance_of_additional_attack = @opponent.agility
            if rand(0.0..5000.0) <= chance_of_additional_attack
                # Check for the statuses of an attack
                if @is_miss == true
                    log_message = "MISS"
                    @combat_logs << log_message

                elsif @is_evade == true
                    log_message = "EVADE"
                    @combat_logs << log_message

                elsif @is_crit == true
                    log_message = "CRITICAL STRIKE"
                    @combat_logs << log_message
                    @character.total_health -= swift_movements.round
                    log_message = "#{@opponent.character_name} attacked for <strong>#{swift_movements}</strong> #{damage_type} damage with 'Swift Movements'"
                elsif @is_ignore_pain == true
                    log_message = "IGNORE PAIN"
                    @combat_logs << log_message
                    @character.total_health -= swift_movements.round
                    log_message = "#{@opponent.character_name} attacked for <strong>#{swift_movements}</strong> #{damage_type} damage with 'Swift Movements'"
                elsif @is_crit == true && @is_ignore_pain == true
                    log_message = "CRITICAL STRIKE"
                    @combat_logs << log_message
                    log_message = "IGNORE PAIN"
                    @combat_logs << log_message
                    @character.total_health -= swift_movements.round
                    log_message = "#{@opponent.character_name} attacked for <strong>#{swift_movements}</strong> #{damage_type} damage with 'Swift Movements'"
                else
                    @character.total_health -= swift_movements.round
                    log_message = "#{@opponent.character_name} attacked for <strong>#{swift_movements}</strong> #{damage_type} damage with 'Swift Movements'"
                end
                    @opponent.apply_combat_skills if @opponent.is_a?(Character)
                    if rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                        sharpened_blade = ((@opponent.total_attack + @opponent.buffed_attack) * 0.5).round
                        @character.total_health -= [(sharpened_blade - (@character.total_armor + @character.buffed_armor)), 0].max
                        log_message += ", <strong>#{sharpened_blade}</strong> physical damage with 'Sharpened Blade' "
                    elsif rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                        poisoned_blade = ((@opponent.total_attack + @opponent.buffed_attack) * 0.5).round
                        @character.total_health -= [(poisoned_blade - (@character.total_magic_resistance + @character.buffed_magic_resistance)), 0].max
                        log_message += ", <strong>#{poisoned_blade}</strong> magic damage with 'Poisoned Blade' "
                    end
                    if @is_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'From the Shadows', unlocked: true).present? && damage.positive?
                        from_the_shadows = (damage * 0.25).round
                        @character.total_health -= [from_the_shadows, 0].max
                        log_message += ", <strong>#{from_the_shadows}</strong> true damage with 'From the Shadows' "
                    end
                    if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Skullsplitter', unlocked: true).present? && damage.positive?
                        skullsplitter = (@character.total_max_health * 0.12).round
                        @character.total_health -= [skullsplitter, 0].max
                        log_message += ", <strong>#{skullsplitter}</strong> additional true damage with 'Skullsplitter' "
                    end
                    if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Judgement', unlocked: true).present? && damage.positive?
                        judgement = (damage * 0.05).round
                        @character.total_health -= [judgement, 0].max
                        log_message += ", <strong>#{judgement}</strong> true damage with 'Judgement' "
                    end
                @combat_logs << log_message
            end
            if @is_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Path of the Dead', unlocked: true).present? && damage.positive?
                path_of_the_dead = (damage * 0.06).round
                @opponent_health_in_combat += [path_of_the_dead, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name} recovered <strong>#{path_of_the_dead}</strong> Health with 'Path of the Dead'"
                @combat_logs << log_message
            end
        end

        # Normal attack
        # Pick the element of attack
        if @opponent.total_attack > @opponent.total_spellpower && @opponent.total_attack > @opponent.total_necrosurge
            damage = [physical_damage(@opponent.total_attack, @opponent.buffed_attack, @character.total_armor, @character.buffed_armor, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.evasion, @character.ignore_pain_chance), 0].max
            damage_type = 'physical'
        elsif @opponent.total_spellpower > @opponent.total_attack  && @opponent.total_spellpower > @opponent.total_necrosurge
            damage = [magic_damage(@opponent.total_spellpower, @opponent.buffed_spellpower, @character.total_magic_resistance, @character.buffed_magic_resistance, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.ignore_pain_chance), 0].max
            damage_type = 'magic'
        elsif @opponent.total_necrosurge > @opponent.total_attack && @opponent.total_necrosurge > @opponent.total_spellpower
            damage = [shadow_damage(@opponent.total_necrosurge, @opponent.buffed_necrosurge, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.evasion, @character.ignore_pain_chance), 0].max
            damage_type = 'shadow'
        end
            # Check for the statuses of an attack
            if @is_miss == true
                log_message = "MISS"
                @combat_logs << log_message

            elsif @is_evade == true
                log_message = "EVADE"
                @combat_logs << log_message

            elsif @is_crit == true
                log_message = "CRITICAL STRIKE"
                @combat_logs << log_message
                @character.total_health -= [damage, 0].max
                if @opponent.is_a?(Character)
                    log_message = "#{@opponent.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                elsif @opponent.is_a?(Monster)
                    log_message = "#{@opponent.monster_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                end
            elsif @is_ignore_pain == true
                log_message = "IGNORE PAIN"
                @combat_logs << log_message
                @character.total_health -= [damage, 0].max
                if @opponent.is_a?(Character)
                    log_message = "#{@opponent.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                elsif @opponent.is_a?(Monster)
                    log_message = "#{@opponent.monster_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                end
            elsif @is_crit == true && @is_ignore_pain == true
                log_message = "CRITICAL STRIKE"
                @combat_logs << log_message
                log_message = "IGNORE PAIN"
                @combat_logs << log_message
                @character.total_health -= [damage, 0].max
                if @opponent.is_a?(Character)
                    log_message = "#{@opponent.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                elsif @opponent.is_a?(Monster)
                    log_message = "#{@opponent.monster_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                end
            else
                @character.total_health -= [damage, 0].max
                if @opponent.is_a?(Character)
                    log_message = "#{@opponent.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                elsif @opponent.is_a?(Monster)
                    log_message = "#{@opponent.monster_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                end
            end

        @opponent.apply_combat_skills if @opponent.is_a?(Character)
            if rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                sharpened_blade = ((@opponent.total_attack + @opponent.buffed_attack) * 0.5).round
                @character.total_health -= [(sharpened_blade - (@character.total_armor + @character.buffed_armor)), 0].max
                log_message += ", <strong>#{sharpened_blade}</strong> physical damage with 'Sharpened Blade' "
            elsif rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                poisoned_blade = ((@opponent.total_attack + @opponent.buffed_attack) * 0.5).round
                @character.total_health -= [(poisoned_blade - (@character.total_magic_resistance + @character.buffed_magic_resistance)), 0].max
                log_message += ", <strong>#{poisoned_blade}</strong> magic damage with 'Poisoned Blade' "
            end
            if @is_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'From the Shadows', unlocked: true).present? && damage.positive?
                from_the_shadows = (damage * 0.25).round
                @character.total_health -= [from_the_shadows, 0].max
                log_message += ", <strong>#{from_the_shadows}</strong> true damage with 'From the Shadows' "
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Skullsplitter', unlocked: true).present? && damage.positive?
                skullsplitter = (@character.total_max_health * 0.12).round
                @character.total_health -= [skullsplitter, 0].max
                log_message += ", <strong>#{skullsplitter}</strong> true damage with 'Skullsplitter' "
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Judgement', unlocked: true).present? && damage.positive?
                judgement = (damage * 0.05).round
                @character.total_health -= [judgement, 0].max
                log_message += ", <strong>#{judgement}</strong> true damage with 'Judgement' "
            end
        @combat_logs << log_message

            if @is_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Path of the Dead', unlocked: true).present? && damage.positive?
                path_of_the_dead = (damage * 0.06).round
                @opponent_health_in_combat += [path_of_the_dead, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name} recovered <strong>#{path_of_the_dead}</strong> Health with 'Path of the Dead'"
                @combat_logs << log_message
            end

            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Crimson Torrent', unlocked:true).present?
                crimson_torrent = (@opponent.total_max_health * 0.03).round
                @character.total_health -= [crimson_torrent, 0].max
                log_message = "#{@opponent.character_name} dealt <strong>#{crimson_torrent}</strong> shadow damage with 'Crimson Torrent'"
                @combat_logs << log_message
            end
            if  @character.skills.find_by(name: 'Deep Wounds', unlocked:true).present?
                deep_wounds = (@opponent.total_max_health * 0.08).round
                @opponent_health_in_combat -= [(deep_wounds - (@opponent.total_armor + @opponent.buffed_armor)), 0].max
                log_message = "#{@character.character_name} dealt <strong>#{deep_wounds}</strong> physical damage with 'Deep Wounds'"
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name:'Lifetap', unlocked:true).present?
                lifetap = (@opponent.total_max_health * 0.01).round
                @opponent_health_in_combat -= [lifetap, 0].max
                lifetap_buff = (lifetap * 2).round
                @opponent.buffed_necrosurge += lifetap_buff
                log_message = "#{@opponent.character_name} sacrificed <strong>#{lifetap}</strong> Health to gain <strong>#{lifetap_buff}</strong> Necrosurge with 'Lifetap'"
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth == true
                ephemeral_rebirth_damage = (@opponnent.total_max_health * 0.10).round
                @opponent_health_in_combat -= ephemeral_rebirth_damage
                log_message = "#{@opponent.character_name} lost <strong>#{ephemeral_rebirth_damage}</strong> Health with 'Ephemeral Rebirth'"
                @combat_logs << log_message
            end

        if @character.total_health <= 0 && @character.skills.find_by(name: 'Nullify', unlocked: true).present? && @character.nullify == false
            @character.total_health = 1
            @character.nullify = true
            log_message = "#{@character.character_name} has triggered 'Nullify' " if @character.nullify == true
            @combat_logs << log_message
        end
        if @character.total_health <= 0 && @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth  == false
            @character.total_health = @character.total_max_health
            @character.ephemeral_rebirth = true
            log_message = "#{@character.character_name} has triggered 'Ephemeral Rebirth' " if @character.ephemeral_rebirth == true
            @combat_logs << log_message
        end

        log_message = "#{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health"
        @combat_logs << log_message

        @character.total_health = [0, @character.total_health].max
        @character.took_damage = true if damage.positive?
        @opponent.took_damage = false
    end

end
