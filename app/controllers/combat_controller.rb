class CombatController < ApplicationController

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

    def combat_result
        combat_result = CombatResult.find(params[:combat_result_id])

        @opponent = combat_result.opponent
        @character = combat_result.character
        @combat_logs = combat_result.combat_logs
        @result = combat_result.result
        @opponent_health_in_combat = combat_result.opponent_health_in_combat

        @hunt = @character.accepted_hunt
    end

    def switch_turns
        @character_turn = !@character_turn
        @opponent_turn = !@opponent_turn
    end

    def combat
        @character = current_user.selected_character
        @opponent = determine_opponent

        if @character.total_health == 0
            flash[:alert] = "You do not have enough Health to engage in combat."
            redirect_back fallback_location: root_path
            return
        end

        # Randomly determine the first turn
        @character_turn = rand(2).zero?
        @opponent_turn = !@character_turn

        # Initialize combat
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

        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats

        # Combat loop
        log_message = '<strong style="font-size: 18px;">Battle has begun</strong>'
        @combat_logs << log_message
        log_message =  "Turn #{@turn_count}"
        if @character_turn
            log_message += ": <strong>#{@character.character_name}</strong> "
        elsif @opponent_turn
            log_message += ": <strong>#{@opponent.character_name}</strong> " if @opponent.is_a?(Character)
            log_message += ": <strong>#{@opponent.monster_name}</strong> " if @opponent.is_a?(Monster)
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
                log_message =  "Turn #{@turn_count}"
                if @character_turn
                    log_message += ": <strong>#{@character.character_name}</strong> "
                elsif @opponent_turn
                    log_message += ": <strong>#{@opponent.character_name}</strong> " if @opponent.is_a?(Character)
                    log_message += ": <strong>#{@opponent.monster_name}</strong> " if @opponent.is_a?(Monster)
                end
                @combat_logs << log_message
            end
            # Check if character or opponent is defeated
            unless @character.total_health.positive? && @opponent_health_in_combat.positive?
                break
            end
        end

        @opponent_health_in_combat
        @character.update_column(:total_health, @character.total_health)

        # Set combat result based on the outcome
        @result = if @character.total_health.positive?
                            '<strong style="font-size: 18px;">Victory</strong>'
                        elsif @opponent_health_in_combat.positive?
                            '<strong style="font-size: 18px;">Defeat</strong>'
                        end

        log_message =  "#{@result}"
        @combat_logs << log_message

        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats

        combat_result = CombatResult.create(
            character: @character,
            opponent: determine_opponent,
            combat_logs: @combat_logs,
            result: @result,
            opponent_health_in_combat: @opponent_health_in_combat
        )

        @hunt.update(combat_result: combat_result) if @hunt.present? && @result == '<strong style="font-size: 18px;">Victory</strong>'

        redirect_to combat_result_path(combat_result_id: combat_result.id)
    end

    def physical_damage(total_attack, buffed_attack, total_armor, buffed_armor, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, total_global_damage, evasion, ignore_pain_chance)
        @is_crit = false

        # Check for a miss with Forged in Battle
        if @character_turn && @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.0) <= 10.00
            damage = 0
            log_message = '<span style="color: green; text-shadow: 1px 1px 2px #000000;">MISS</span>'
            @combat_logs << log_message
        elsif @opponent_turn && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            log_message = '<span style="color: green; text-shadow: 1px 1px 2px #000000;">MISS</span>'
            @combat_logs << log_message
        else
            # Chance to evade damage
            if rand(0.00..100.00) <= evasion
                damage = 0
                log_message = '<span style="color: yellow; text-shadow: 1px 1px 2px #000000;">EVADED</span>'
                @combat_logs << log_message
            else
                # Check for a critical hit based on critical_strike_chance
                if rand(0.00..100.00) <= (total_critical_strike_chance + buffed_critical_strike_chance)
                    damage = (((total_attack + buffed_attack) + ((total_attack + buffed_attack) * total_global_damage)) * (total_critical_strike_damage + buffed_critical_strike_damage)) - (total_armor + buffed_armor)
                    log_message = '<span style="color: red; text-shadow: 1px 1px 2px #000000;">CRITICAL STRIKE</span>'
                    @combat_logs << log_message
                    @is_crit = true
                else
                    damage = ((total_attack + buffed_attack) + ((total_attack + buffed_attack) * total_global_damage)) - (total_armor + buffed_armor)

                    # Apply damage reduction based on ignore_pain_chance
                    if rand(0.00..100.00) <= ignore_pain_chance
                        damage *= 0.8  # Reduce incoming damage by 20%
                        log_message = '<span style="color: blue; text-shadow: 1px 1px 2px #000000;">IGNORE PAIN</span>'
                        @combat_logs << log_message
                    end
                end
            end
        end

        damage.round
    end

    def magic_damage(total_spellpower, buffed_spellpower, total_magic_resistance, buffed_magic_resistance, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, total_global_damage, ignore_pain_chance)
        @is_crit = false

        # Check for a miss with Forged in Battle
        if @character_turn && @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            log_message = '<span style="color: green; text-shadow: 1px 1px 2px #000000;">MISS</span>'
            @combat_logs << log_message
        elsif @opponent_turn && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            log_message = '<span style="color: green; text-shadow: 1px 1px 2px #000000;">MISS</span>'
            @combat_logs << log_message
        else
            # Check for a critical hit based on critical_strike_chance
            if rand(0.00..100.00) <= (total_critical_strike_chance + buffed_critical_strike_chance)
                damage = (((total_spellpower + buffed_spellpower) + ((total_spellpower + buffed_spellpower) * total_global_damage)) * (total_critical_strike_damage + buffed_critical_strike_damage)) - (total_magic_resistance + buffed_magic_resistance)
                log_message = '<span style="color: red; text-shadow: 1px 1px 2px #000000;">CRITICAL STRIKE</span>'
                @combat_logs << log_message
                @is_crit = true
            else
                damage = ((total_spellpower + buffed_spellpower) + ((total_spellpower + buffed_spellpower) * total_global_damage)) - (total_magic_resistance + buffed_magic_resistance)
                # Apply damage reduction based on ignore_pain_chance
                if rand(0.00..100.00) <= ignore_pain_chance
                    damage *= 0.8  # Reduce incoming damage by 20%
                    log_message = '<span style="color: blue; text-shadow: 1px 1px 2px #000000;">IGNORE PAIN</span>'
                    @combat_logs << log_message
                end
            end
        end

        damage.round
    end

    def shadow_damage(total_necrosurge, buffed_necrosurge, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, total_global_damage, evasion, ignore_pain_chance)
        @is_crit = false

        # Check for a miss with Forged in Battle
        if @character_turn && @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            log_message = '<span style="color: green; text-shadow: 1px 1px 2px #000000;">MISS</span>'
            @combat_logs << log_message
        elsif @opponent_turn && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 10.00
            damage = 0
            log_message = '<span style="color: green; text-shadow: 1px 1px 2px #000000;">MISS</span>'
            @combat_logs << log_message
        else
            # Chance to evade damage
            if rand(0.00..100.00) <= evasion
                damage = 0
                log_message = '<span style="color: yellow; text-shadow: 1px 1px 2px #000000;">EVADED</span>'
                @combat_logs << log_message
            else
                # Check for a critical hit based on critical strike chance
                if rand(0.00..100.00) <= (total_critical_strike_chance + buffed_critical_strike_chance)
                    damage = (((total_necrosurge + buffed_necrosurge) + ((total_necrosurge + buffed_necrosurge) * total_global_damage)) * (total_critical_strike_damage + buffed_critical_strike_damage))
                    log_message = '<span style="color: red; text-shadow: 1px 1px 2px #000000;">CRITICAL STRIKE</span>'
                    @combat_logs << log_message
                    @is_crit = true
                else
                    damage = ((total_necrosurge + buffed_necrosurge) + ((total_necrosurge + buffed_necrosurge) * total_global_damage))

                    # Apply damage reduction based on ignore_pain_chance
                    if rand(0.00..100.00) <= ignore_pain_chance
                        damage *= 0.8  # Reduce incoming damage by 20%
                        log_message = '<span style="color: blue; text-shadow: 1px 1px 2px #000000;">IGNORE PAIN</span>'
                        @combat_logs << log_message
                    end
                end
            end
        end

        damage.round
    end

    def character_turn
        if @character.took_damage == true
            @character.apply_trigger_skills
            if @character.skills.find_by(name: 'Surge of Light', unlocked: true).present?
                surge_of_light = (@character.total_max_health * 0.02).round
                @character.total_health += [surge_of_light, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name} recovered <strong>#{surge_of_light}</strong> Health with 'Surge of Light' "
                log_message += "- #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
                @combat_logs << log_message
            end
        end

        if @character.skills.find_by(name: 'Piety', unlocked: true).present? && (@character.total_health <= (@character.total_max_health * 0.5 )) && @character.piety == false
            piety = (@character.total_max_health * 0.20).round
            @character.total_health += [piety, @character.total_max_health - @character.total_health].min
            @character.piety = true
            log_message = "#{@character.character_name} recovered <strong>#{piety}</strong> Health with 'Piety' "
            log_message += "- #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
            @combat_logs << log_message
        end

        deal_damage(@character, @opponent)
            if @character.skills.find_by(name: 'Crimson Torrent', unlocked:true).present?
                crimson_torrent = (@character.total_max_health * 0.03).round
                @opponent_health_in_combat -= [crimson_torrent, 0].max
                log_message = "#{@character.character_name} dealt <strong>#{crimson_torrent}</strong> shadow damage with 'Crimson Torrent' "
                    if @opponent.is_a?(Character)
                        log_message += "- #{@opponent.character_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
                    elsif @opponent.is_a?(Monster)
                        log_message += "- #{@opponent.monster_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
                    end
                @combat_logs << log_message
            end
            if @character.skills.find_by(name:'Lifetap', unlocked:true).present?
                lifetap = (@character.total_max_health * 0.01).round
                @character.total_health -= [lifetap, 0].max
                @character.buffed_necrosurge += lifetap
                log_message = "#{@character.character_name} sacrificed <strong>#{lifetap}</strong> Health to gain <strong>#{lifetap}</strong> Necrosurge with 'Lifetap' "
                log_message += "- #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
                @combat_logs << log_message
            end

        @opponent_health_in_combat = [0, @opponent_health_in_combat].max
        @character.apply_combat_skills
        @character.took_damage = false
    end

    def opponent_turn
        if @opponent.took_damage == true && @opponent.is_a?(Character)
            @opponent.apply_trigger_skills
            if @opponent.skills.find_by(name: 'Surge of Light', unlocked: true).present?
                surge_of_light = (@opponent.total_max_health * 0.02).round
                @opponent_health_in_combat += [surge_of_light, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name} recovered <strong>#{surge_of_light}</strong> Health with 'Surge of Light' "
                log_message += "- #{@opponent.character_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
                @combat_logs << log_message
            end
        end

        if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Piety', unlocked: true).present? && (@opponent_health_in_combat <= (@opponent.total_max_health* 0.50 )) && @opponent.piety == false
            piety = (@opponent.total_max_health * 0.20).round
            @opponent_health_in_combat += [piety, @opponent.total_max_health - @opponent_health_in_combat].min
            @opponent.piety = true
            log_message = "#{@opponent.character_name} recovered <strong>#{piety}</strong> Health with 'Piety' "
            log_message += "- #{@opponent.character_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
            @combat_logs << log_message
        end

        deal_damage(@opponent, @character)
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Crimson Torrent', unlocked:true).present?
                crimson_torrent = (@opponent.total_max_health * 0.03).round
                @character.total_health -= [crimson_torrent, 0].max
                log_message = "#{@opponent.character_name} dealt <strong>#{crimson_torrent}</strong> shadow damage with 'Crimson Torrent' "
                log_message += "- #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name:'Lifetap', unlocked:true).present?
                lifetap = (@opponent.total_max_health * 0.01).round
                @opponent_health_in_combat -= [lifetap, 0].max
                @opponent.buffed_necrosurge += lifetap
                log_message = "#{@opponent.character_name} sacrificed <strong>#{lifetap}</strong> Health to gain <strong>#{lifetap}</strong> Necrosurge with 'Lifetap' "
                log_message += "- #{@opponent.character_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
                @combat_logs << log_message
            end

        @character.total_health = [0, @character.total_health].max
        @opponent.apply_combat_skills if @opponent.is_a?(Character)
        @opponent.took_damage = false
    end

    def deal_damage(character, opponent)
        if @character_turn
            damage = 0
            damage_type = ''

            if @character.total_attack > @character.total_spellpower && @character.total_attack > @character.total_necrosurge
                damage = [physical_damage(@character.total_attack, @character.buffed_attack, @opponent.total_armor, @opponent.buffed_armor, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.evasion, @opponent.ignore_pain_chance).round, 0].max
                damage_type = 'physical'
            elsif @character.total_spellpower > @character.total_attack && @character.total_spellpower > @character.total_necrosurge
                damage = [magic_damage(@character.total_spellpower, @character.buffed_spellpower, @opponent.total_magic_resistance, @opponent.buffed_magic_resistance, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.ignore_pain_chance).round, 0].max
                damage_type = 'magic'
            elsif @character.total_necrosurge > @character.total_attack && @character.total_necrosurge > @character.total_spellpower
                damage = [shadow_damage(@character.total_necrosurge, @character.buffed_necrosurge, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @character.total_global_damage, @opponent.evasion, @opponent.ignore_pain_chance).round, 0].max
                damage_type = 'shadow'
            end

            if damage.positive?
                if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Blood Monarch', unlocked: true).present?
                    if @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth == true
                        @opponent_health_in_combat -= [(damage * 2.2).round, 0].max
                    else
                        @opponent_health_in_combat -= [(damage * 1.2).round, 0].max
                    end
                elsif @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true) && @opponent.ephemeral_rebirth == true
                    @opponent_health_in_combat -= [(damage * 2.0).round, 0].max
                else
                    @opponent_health_in_combat -= [damage, 0].max
                end

                log_message = "#{@character.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "

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

            if @character.skills.find_by(name: 'Judgement', unlocked: true).present?
                judgement = (damage * 0.05).round
                @opponent_health_in_combat -= [judgement, 0].max
                log_message += ", <strong>#{judgement}</strong> true damage with 'Judgement' "
            end

                @opponent.took_damage = true if damage.positive?

            if @opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Nullify', unlocked: true).present? && @opponent.nullify == false
                @opponent_health_in_combat += 1
                @opponent.nullify = true
                log_message += ". #{@opponent.character_name} has triggered 'Nullify' " if @opponent.nullify == true
            end

            if @opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth  == false
                @opponent_health_in_combat = @opponent.total_max_health
                @opponent.ephemeral_rebirth = true
                log_message += ". #{@opponent.character_name} has triggered 'Ephemeral Rebirth' " if @opponent.ephemeral_rebirth == true
            end

            if @opponent.is_a?(Character)
                log_message += "- #{@opponent.character_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
            elsif @opponent.is_a?(Monster)
                log_message += "- #{@opponent.monster_name} : #{@opponent_health_in_combat} / #{@opponent.total_max_health} Health "
            end

            @combat_logs << log_message

            if @character.skills.find_by(name: 'Blood Frenzy', unlocked: true).present?
                blood_frenzy = (damage * 0.08).round
                @character.total_health += [blood_frenzy, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name} recovered <strong>#{blood_frenzy}</strong> Health with 'Blood Frenzy' - #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} "
                @combat_logs << log_message
            end

            else
                log_message = "#{@character.character_name} dealt no damage "
                @combat_logs << log_message
            end

        @opponent_health_in_combat = [0, @opponent_health_in_combat].max

        elsif @opponent_turn
            damage = 0
            damage_type = ''

            if @opponent.total_attack > @opponent.total_spellpower && @opponent.total_attack > @opponent.total_necrosurge
                damage = [physical_damage(@opponent.total_attack, @opponent.buffed_attack, @character.total_armor, @character.buffed_armor, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.evasion, @character.ignore_pain_chance).round, 0].max
                damage_type = 'physical'
            elsif @opponent.total_spellpower > @opponent.total_attack  && @opponent.total_spellpower > @opponent.total_necrosurge
                damage = [magic_damage(@opponent.total_spellpower, @opponent.buffed_spellpower, @character.total_magic_resistance, @character.buffed_magic_resistance, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.ignore_pain_chance).round, 0].max
                damage_type = 'magic'
            elsif @opponent.total_necrosurge > @opponent.total_attack && @opponent.total_necrosurge > @opponent.total_spellpower
                damage = [shadow_damage(@opponent.total_necrosurge, @opponent.buffed_necrosurge, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @opponent.total_global_damage, @character.evasion, @character.ignore_pain_chance).round, 0].max
                damage_type = 'shadow'
            end

            if damage.positive?
                if @character.skills.find_by(name: 'Blood Monarch', unlocked: true).present?
                    if @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth == true
                        @character.total_health -= [(damage * 2.2).round, 0].max
                    else
                        @character.total_health -= [(damage * 1.2).round, 0].max
                    end
                elsif @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth == true
                    @character.total_health -= [(damage * 2.0).round, 0].max
                else
                    @character.total_health -= [damage, 0].max
                end

                if @opponent.is_a?(Character)
                    log_message = "#{@opponent.character_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                elsif @opponent.is_a?(Monster)
                    log_message = "#{@opponent.monster_name} attacked for <strong>#{damage}</strong> #{damage_type} damage "
                end

                if rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                    sharpened_blade = ((@opponent.total_attack + @opponent.buffed_attack) * 0.5).round
                    @character.total_health -= [(sharpened_blade - (@character.total_armor + @character.buffed_armor)), 0].max
                    log_message += ", <strong>#{sharpened_blade}</strong> physical damage with 'Sharpened Blade' "
                elsif rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                    poisoned_blade = ((@opponent.total_attack + @opponent.buffed_attack) * 0.5).round
                    @character.total_health -= [(poisoned_blade - (@character.total_magic_resistance + @character.buffed_magic_resistance)), 0].max
                    log_message += ", <strong>#{poisoned_blade}</strong> magic damage with 'Poisoned Blade' "
                end

                if @is_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                    from_the_shadows = (damage * 0.25).round
                    @character.total_health -= [from_the_shadows, 0].max
                    log_message += ", <strong>#{from_the_shadows}</strong> true damage with 'From the Shadows' "
                end

                if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Judgement', unlocked: true).present?
                    judgement = (damage * 0.05).round
                    @character.total_health -= [judgement, 0].max
                    log_message += ", <strong>#{judgement}</strong> true damage with 'Judgement' "
                end

                @character.took_damage = true if damage.positive?

                if @character.total_health <= 0 && @character.skills.find_by(name: 'Nullify', unlocked: true).present? && @character.nullify == false
                    @character.total_health += 1
                    @character.nullify = true
                    log_message += ". #{@character.character_name} has triggered 'Nullify' " if @character.nullify == true
                end

                if @character.total_health <= 0 && @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth  == false
                    @character.total_health = @character.total_max_health
                    @character.ephemeral_rebirth = true
                    log_message += ". #{@character.character_name} has triggered 'Ephemeral Rebirth' " if @character.ephemeral_rebirth == true
                end

                log_message += "- #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
                @combat_logs << log_message

                if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Blood Frenzy', unlocked: true).present?
                    blood_frenzy = (damage * 0.08).round
                    @opponent_health_in_combat += [blood_frenzy, @opponent.total_max_health - @opponent_health_in_combat].min
                    log_message = "#{@opponent.character_name} recovered <strong>#{blood_frenzy}</strong> Health with 'Blood Frenzy' - #{@opponent_health_in_combat} / #{@opponent.total_max_health} "
                    @combat_logs << log_message
                end

            else
                if @opponent.is_a?(Character)
                    log_message = "#{@opponent.character_name} dealt no damage "
                elsif @opponent.is_a?(Monster)
                      log_message = "#{@opponent.monster_name} dealt no damage "
                end

                @combat_logs << log_message
            end

        @character.total_health = [0, @character.total_health].max

        end
    end

end
