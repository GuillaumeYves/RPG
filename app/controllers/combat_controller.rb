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
        @character_deep_wounds_turn = 0
        @opponent_deep_wounds_turn = 0
        @character_attack = (@character.total_min_attack + @character.total_max_attack)
        @character_spellpower = (@character.total_min_spellpower + @character.total_max_spellpower)
        @character_necrosurge = (@character.total_min_necrosurge + @character.total_max_necrosurge)
        @opponent_attack = (@opponent.total_min_attack + @opponent.total_max_attack)
        @opponent_spellpower = (@opponent.total_min_spellpower + @opponent.total_max_spellpower)
        @opponent_necrosurge = (@opponent.total_min_necrosurge + @opponent.total_max_necrosurge)
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
                @character_deep_wounds_turn -= 1 if @character_deep_wounds_turn > 0
                @opponent_deep_wounds_turn -= 1 if @opponent_deep_wounds_turn > 0

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

    def physical_damage
        # Initiate attack variables
        @character_has_missed = false
        @character_has_evaded = false
        @character_has_crit = false
        @character_has_ignored_pain = false
        @opponent_has_missed = false
        @opponent_has_evaded = false
        @opponent_has_crit = false
        @opponent_has_ignored_pain = false
        # Character's turn
        if @character_turn
            if @character.neck.present? && @character.neck.name == "The Nexus"
                damage_roll = rand((@character.total_min_attack + @character.buffed_min_attack)..(@character.total_max_attack + @character.buffed_max_attack))
            else
                damage_roll = (@character.total_max_attack + @character.buffed_max_attack)
            end
            # Check for a miss with Forged in Battle
            if @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 20.00
                damage = 0
                @character_has_missed = true
            else
                # Chance to evade damage
                if rand(0.00..100.00) <= @opponent.evasion
                    if @character.skills.find_by(name: 'Undeniable', unlocked: true).present?
                        damage = ((damage_roll + (damage_roll * @character.total_global_damage)) - (@opponent.total_armor + @opponent.buffed_armor))
                    else
                        damage = 0
                        @opponent_has_evaded = true
                    end
                else
                    # Check for a critical hit based on critical_strike_chance
                    if rand(0.00..100.00) <= (@character.total_critical_strike_chance + @character.buffed_critical_strike_chance)
                        damage =  (((damage_roll + (damage_roll * @character.total_global_damage)) * (@character.total_critical_strike_damage + @character.buffed_critical_strike_damage)) - (@opponent.total_armor + @opponent.buffed_armor))
                        @character_has_crit = true
                    else
                        damage = ((damage_roll + (damage_roll * @character.total_global_damage)) - (@opponent.total_armor + @opponent.buffed_armor))
                        # Apply damage reduction based on ignore_pain_chance
                        if rand(0.00..100.00) <= @opponent.ignore_pain_chance
                            damage *= 0.8  # Reduce incoming damage by 20%
                            @opponent_has_ignored_pain = true
                        end
                    end
                end
                if @character.main_hand.present? && @character.main_hand.name == "Nemesis" && @opponent_health_in_combat >= (@opponent.total_max_health * 0.70)
                    [(damage * 1.5).round, 0].max # Return damage with Nemesis
                else
                    [damage.round, 0].max # Return damage
                end
            end
        # Opponent's turn
        elsif @opponent_turn
            if @opponent.is_a?(Character) && @opponent.neck.present? && @opponent.neck.name == "The Nexus"
                damage_roll = (@opponent.total_max_attack + @opponent.buffed_max_attack)
            else
                damage_roll = rand((@opponent.total_min_attack + @opponent.buffed_min_attack)..(@opponent.total_max_attack + @opponent.buffed_max_attack))
            end
            # Check for a miss with Forged in Battle
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 20.00
                damage = 0
                @opponent_has_missed = true
            else
                # Chance to evade damage
                if rand(0.00..100.00) <= @character.evasion
                    if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Undeniable', unlocked: true).present?
                        damage = ((damage_roll + (damage_roll * @opponent.total_global_damage)) - (@character.total_armor + @character.buffed_armor))
                    else
                        damage = 0
                        @character_has_evaded = true
                    end
                else
                    # Check for a critical hit based on critical_strike_chance
                    if rand(0.00..100.00) <= (@opponent.total_critical_strike_chance + @opponent.buffed_critical_strike_chance)
                        damage =  (((damage_roll + (damage_roll * @opponent.total_global_damage)) * (@opponent.total_critical_strike_damage + @opponent.buffed_critical_strike_damage)) - (@character.total_armor + @character.buffed_armor))
                        @opponent_has_crit = true
                    else
                        damage = ((damage_roll + (damage_roll * @opponent.total_global_damage)) - (@character.total_armor + @character.buffed_armor))
                        # Apply damage reduction based on ignore_pain_chance
                        if rand(0.00..100.00) <= @character.ignore_pain_chance
                            damage *= 0.8  # Reduce incoming damage by 20%
                            @character_has_ignored_pain = true
                        end
                    end
                end
            end
        end
        if @opponent.is_a?(Character) && @opponent.main_hand.present? && @opponent.main_hand.name == "Nemesis" && @character.total_health >= (@character.total_max_health * 0.70)
            [(damage * 1.5).round, 0].max # Return damage with Nemesis
        else
            [damage.round, 0].max # Return damage
        end
    end

    def magic_damage
        # Initiate attack variables
        @character_has_missed = false
        @character_has_evaded = false
        @character_has_crit = false
        @character_has_ignored_pain = false
        @opponent_has_missed = false
        @opponent_has_evaded = false
        @opponent_has_crit = false
        @opponent_has_ignored_pain = false
        # Character's turn
        if @character_turn
            if @character.neck.present? && @character.neck.name == "The Nexus"
                damage_roll = (@character.total_max_spellpower + @character.buffed_max_spellpower)
            else
                damage_roll = rand((@character.total_min_spellpower + @character.buffed_min_spellpower)..(@character.total_max_spellpower + @character.buffed_max_spellpower))
            end
            # Check for a miss with Forged in Battle
            if @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 20.00
                damage = 0
                @character_has_missed = true
            else
                # Check for a critical hit based on critical_strike_chance
                if rand(0.00..100.00) <= (@character.total_critical_strike_chance + @character.buffed_critical_strike_chance)
                    damage =  (((damage_roll + (damage_roll * @character.total_global_damage)) * (@character.total_critical_strike_damage + @character.buffed_critical_strike_damage)) - (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance))
                    @character_has_crit = true
                else
                    damage = ((damage_roll + (damage_roll * @character.total_global_damage)) - (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance))
                    # Apply damage reduction based on ignore_pain_chance
                    if rand(0.00..100.00) <= @opponent.ignore_pain_chance
                        damage *= 0.8  # Reduce incoming damage by 20%
                        @opponent_has_ignored_pain = true
                    end
                end
                if @character.main_hand.present? && @character.main_hand.name == "Nemesis" && @opponent_health_in_combat >= (@opponent.total_max_health * 0.70)
                    [(damage * 1.5).round, 0].max # Return damage with Nemesis
                else
                    [damage.round, 0].max # Return damage
                end
            end
        # Opponent's turn
        elsif @opponent_turn
            if @opponent.is_a?(Character) && @opponent.neck.present? && @opponent.neck.name == "The Nexus"
                damage_roll = (@opponent.total_max_spellpower + @opponent.buffed_max_spellpower)
            else
                damage_roll = rand((@opponent.total_min_spellpower + @opponent.buffed_min_spellpower)..(@opponent.total_max_spellpower + @opponent.buffed_max_spellpower))
            end
            # Check for a miss with Forged in Battle
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 20.00
                damage = 0
                @opponent_has_missed = true
            else
                # Check for a critical hit based on critical_strike_chance
                if rand(0.00..100.00) <= (@opponent.total_critical_strike_chance + @opponent.buffed_critical_strike_chance)
                    damage =  (((damage_roll + (damage_roll * @opponent.total_global_damage)) * (@opponent.total_critical_strike_damage + @opponent.buffed_critical_strike_damage)) - (@character.total_magic_resistance + @character.buffed_magic_resistance))
                    @opponent_has_crit = true
                else
                    damage = (damage_roll + (damage_roll * @opponent.total_global_damage) - (@character.total_magic_resistance + @character.buffed_magic_resistance))
                    # Apply damage reduction based on ignore_pain_chance
                    if rand(0.00..100.00) <= @character.ignore_pain_chance
                        damage *= 0.8  # Reduce incoming damage by 20%
                        @character_has_ignored_pain = true
                    end
                end
            end
        end
        if @opponent.is_a?(Character) && @opponent.main_hand.present? && @opponent.main_hand.name == "Nemesis" && @character.total_health >= (@character.total_max_health * 0.70)
            [(damage * 1.5).round, 0].max # Return damage with Nemesis
        else
            [damage.round, 0].max # Return damage
        end
    end

    def shadow_damage
        # Initiate attack variables
        @character_has_missed = false
        @character_has_evaded = false
        @character_has_crit = false
        @character_has_ignored_pain = false
        @opponent_has_missed = false
        @opponent_has_evaded = false
        @opponent_has_crit = false
        @opponent_has_ignored_pain = false
        # Character's turn
        if @character_turn
            if @character.neck.present? && @character.neck.name == "The Nexus"
                damage_roll = (@character.total_max_necrosurge + @character.buffed_max_necrosurge)
            else
                damage_roll = rand((@character.total_min_necrosurge + @character.buffed_min_necrosurge)..(@character.total_max_necrosurge + @character.buffed_max_necrosurge))
            end
            # Check for a miss with Forged in Battle
            if @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 20.00
                damage = 0
                @character_has_missed = true
            else
                # Chance to evade damage
                if rand(0.00..100.00) <= @opponent.evasion
                    if @character.skills.find_by(name: 'Undeniable', unlocked: true).present?
                        damage = (damage_roll + (damage_roll * @character.total_global_damage))
                    else
                        damage = 0
                        @opponent_has_evaded = true
                    end
                else
                    # Check for a critical hit based on critical_strike_chance
                    if rand(0.00..100.00) <= (@character.total_critical_strike_chance + @character.buffed_critical_strike_chance)
                        damage =  ((damage_roll + (damage_roll * @character.total_global_damage) * (@character.total_critical_strike_damage + @character.buffed_critical_strike_damage)))
                        @character_has_crit = true
                    else
                        damage = (damage_roll + (damage_roll * @character.total_global_damage))
                        # Apply damage reduction based on ignore_pain_chance
                        if rand(0.00..100.00) <= @opponent.ignore_pain_chance
                            damage *= 0.8  # Reduce incoming damage by 20%
                            @opponent_has_ignored_pain = true
                        end
                    end
                end
                if @character.main_hand.present? && @character.main_hand.name == "Nemesis" && @opponent_health_in_combat >= (@opponent.total_max_health * 0.70)
                    [(damage * 1.5).round, 0].max # Return damage with Nemesis
                else
                    [damage.round, 0].max # Return damage
                end
            end
        # Opponent's turn
        elsif @opponent_turn
            if @opponent.is_a?(Character) && @opponent.neck.present? && @opponent.neck.name == "The Nexus"
                damage_roll = (@opponent.total_max_necrosurge + @opponent.buffed_max_necrosurge)
            else
                damage_roll = rand((@opponent.total_min_necrosurge + @opponent.buffed_min_necrosurge)..(@opponent.total_max_necrosurge + @opponent.buffed_max_necrosurge))
            end
            # Check for a miss with Forged in Battle
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 20.00
                damage = 0
                @opponent_has_missed = true
            else
                # Chance to evade damage
                if rand(0.00..100.00) <= @character.evasion
                    if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Undeniable', unlocked: true).present?
                        damage = (damage_roll + (damage_roll * @opponent.total_global_damage))
                    else
                        damage = 0
                        @character_has_evaded = true
                    end
                else
                    # Check for a critical hit based on critical_strike_chance
                    if rand(0.00..100.00) <= (@opponent.total_critical_strike_chance + @opponent.buffed_critical_strike_chance)
                        damage =  ((damage_roll + (damage_roll * @opponent.total_global_damage) * (@opponent.total_critical_strike_damage + @opponent.buffed_critical_strike_damage)))
                        @opponent_has_crit = true
                    else
                        damage = (damage_roll + (damage_roll * @opponent.total_global_damage))
                        # Apply damage reduction based on ignore_pain_chance
                        if rand(0.00..100.00) <= @character.ignore_pain_chance
                            damage *= 0.8  # Reduce incoming damage by 20%
                            @character_has_ignored_pain = true
                        end
                    end
                end
            end
        end
        if @opponent.is_a?(Character) && @opponent.main_hand.present? && @opponent.main_hand.name == "Nemesis" && @character.total_health >= (@character.total_max_health * 0.70)
            [(damage * 1.5).round, 0].max # Return damage with Nemesis
        else
            [damage.round, 0].max # Return damage
        end
    end

    def character_turn
        # Initiate the variables
        damage = 0
        swift_movements = 0
        damage_type = ''

        # Apply the trigger skills
        if @character.took_damage == true
            @character.apply_trigger_skills
            if @character.skills.find_by(name: 'Surge of Light', unlocked: true).present?
                surge_of_light = (@character.total_max_health * 0.02).round
                surge_of_light_image = "<img src='/assets/paladin_skills/surgeoflight.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health += [surge_of_light, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name}: #{surge_of_light_image} Surge of Light - <strong>#{surge_of_light}</strong> Health recovery"
                @combat_logs << log_message
            end
        end
        if @character.skills.find_by(name: 'Piety', unlocked: true).present? && (@character.total_health <= (@character.total_max_health * 0.5 )) && @character.piety == false
            piety = (@character.total_max_health * 0.20).round
            piety_image = "<img src='/assets/paladin_skills/piety.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            @character.total_health += [piety, @character.total_max_health - @character.total_health].min
            @character.piety = true
            log_message = "#{@character.character_name}: #{piety_image} Piety - <strong>#{piety}</strong> Health recovery"
            @combat_logs << log_message
        end
            # Swift movements - Rogue talent
            if @character.skills.find_by(name: 'Swift Movements', unlocked: true).present?
                # Picks the element of attack
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    swift_movements = (physical_damage * 0.5).round
                    damage_type = 'physical'
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    swift_movements = (magic_damage * 0.5).round
                    damage_type = 'magic'
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    swift_movements = (shadow_damage * 0.5).round
                    damage_type = 'shadow'
                end
                chance_of_additional_attack = @character.agility
                if rand(0.0..5000.0) <= chance_of_additional_attack
                    swift_movements_image = "<img src='/assets/rogue_skills/swiftmovements.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    # Check for the statuses of an attack
                    if swift_movements == 0
                        if @character_has_missed == true
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - ❌ (MISS)"
                        elsif @opponent_has_evaded == true
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - 🚫 (EVADE)"
                        end
                    else
                        if @character_has_crit == true && @opponent_has_ignored_pain == true
                            @opponent_health_in_combat -= swift_movements
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{swift_movements}</strong> #{damage_type} damage"
                        elsif @character_has_crit == true
                            @opponent_health_in_combat -= swift_movements
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - ❗ (CRITICAL STRIKE) <strong>#{swift_movements}</strong> #{damage_type} damage"
                        elsif @opponent_has_ignored_pain == true
                            @opponent_health_in_combat -= swift_movements
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - 🛡️ (IGNORE PAIN) <strong>#{swift_movements}</strong> #{damage_type} damage"
                        else
                            @opponent_health_in_combat -= swift_movements
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - <strong>#{swift_movements}</strong> #{damage_type} damage"
                        end
                    end
                    # Apply combat skills
                    @character.apply_combat_skills
                        # Proceed with diverse triggers after attacking
                        if rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                            sharpened_blade_image = "<img src='/assets/rogue_skills/sharpenedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                            sharpened_blade = (physical_damage * 0.5).round
                            @opponent_health_in_combat -= [sharpened_blade, 0].max
                            log_message += ", #{sharpened_blade_image} Sharpened Blade - <strong>#{sharpened_blade}</strong> additional physical damage"
                        elsif rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                            poisoned_blade_image = "<img src='/assets/rogue_skills/poisonedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                            poisoned_blade = (magic_damage * 0.5).round
                            @opponent_health_in_combat -= [poisoned_blade, 0].max
                            log_message += ", #{poisoned_blade_image} Poisoned Blade - <strong>#{poisoned_blade}</strong> additional magic damage"
                        end
                        if swift_movements.positive? && @character_has_crit == true && @character.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                            from_the_shadows_image = "<img src='/assets/rogue_skills/fromtheshadows.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                            from_the_shadows = (swift_movements * 0.25).round
                            @opponent_health_in_combat -= [from_the_shadows, 0].max
                            log_message += ", #{from_the_shadows_image} From the Shadows - <strong>#{from_the_shadows}</strong> additional true damage"
                        end
                    @combat_logs << log_message
                end
                # After attack healing
            # Apply combat skills
            @character.apply_combat_skills
            end

        # Normal attack
        # Pick the element of attack
        if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
            damage = [physical_damage, 0].max
            damage_type = 'physical'
        elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
            damage = [magic_damage, 0].max
            damage_type = 'magic'
        elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
            damage = [shadow_damage, 0].max
            damage_type = 'shadow'
        end
            # Check for the statuses of an attack
            if damage == 0
                if @character_has_missed == true
                    log_message = "#{@character.character_name}: ⚔️ Basic attack - ❌ (MISS)"
                elsif @opponent_has_evaded == true
                    log_message = "#{@character.character_name}: ⚔️ Basic attack - 🚫 (EVADE)"
                else
                    log_message = "#{@character.character_name}: ⚔️ Basic attack - Damage has been mitigated"
                end
            else
                if @character_has_crit == true && @opponent_has_ignored_pain == true
                    @opponent_health_in_combat -= damage
                    log_message = "#{@character.character_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                elsif @character_has_crit == true
                    @opponent_health_in_combat -= damage
                    log_message = "#{@character.character_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                elsif @opponent_has_ignored_pain == true
                    @opponent_health_in_combat -= damage
                    log_message = "#{@character.character_name}: ⚔️ Basic attack - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                else
                    @opponent_health_in_combat -= damage
                    log_message = "#{@character.character_name}: ⚔️ Basic attack - <strong>#{damage}</strong> #{damage_type} damage"
                end
            end
                # Proceed with diverse triggers after attacking
                # Ruler of Storms
                if damage.positive? && (@character.main_hand.present? && @character.main_hand.name == "Ruler of Storms") || (@character.off_hand.present? && @character.off_hand.name == "Ruler of Storms")
                    rulerofstorms_image = "<img src='/assets/legendary_items/rulerofstorms.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                    rulerofstorms_damage = [((damage * 0.2).round), 0].max
                    @opponent_health_in_combat -= [rulerofstorms_damage, 0].max
                    log_message += ", #{rulerofstorms_image} Sentence of the Skies - <strong>#{rulerofstorms_damage}</strong> additional magic damage"
                end
                # Sharpened Blade - Rogue talent
                if rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                    sharpened_blade_image = "<img src='/assets/rogue_skills/sharpenedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    sharpened_blade = [(physical_damage * 0.5).round, 0].max
                    @opponent_health_in_combat -= [sharpened_blade, 0].max
                    log_message += ", #{sharpened_blade_image} Sharpened Blade - <strong>#{sharpened_blade}</strong> additional physical damage"
                # Poisened Blade - Rogue talent
                elsif rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                    poisoned_blade_image = "<img src='/assets/rogue_skills/poisonedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    poisoned_blade = [(magic_damage * 0.5).round, 0].max
                    @opponent_health_in_combat -= [poisoned_blade, 0].max
                    log_message += ", #{poisoned_blade_image} Poisoned Blade - <strong>#{poisoned_blade}</strong> additional magic damage"
                end
                # From the Shadows - Rogue talent
                if damage.positive? && @character_has_crit == true && @character.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                    from_the_shadows_image = "<img src='/assets/rogue_skills/fromtheshadows.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    from_the_shadows = [(damage * 0.25).round, 0].max
                    @opponent_health_in_combat -= [from_the_shadows, 0].max
                    log_message += ", #{from_the_shadows_image} From the Shadows: <strong>#{from_the_shadows}</strong> additional true damage"
                end
                # Skullsplitter - Warrior talent
                if damage.positive? && @character_has_crit == true && @character.skills.find_by(name: 'Skullsplitter', unlocked: true).present? && !(@character.main_hand.name == 'Hellbound' || @character.off_hand.name == 'Hellbound')
                    skullsplitter_image = "<img src='/assets/warrior_skills/skullsplitter.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    skullsplitter = [(@opponent.total_max_health * 0.03).round, 0].max
                    @opponent_health_in_combat -= [skullsplitter, 0].max
                    log_message += ", #{skullsplitter_image} Skullsplitter - <strong>#{skullsplitter}</strong> additional true damage"
                end
                # Deep Wounds - Warrior talent (initialize)
                if damage.positive? && @character.skills.find_by(name: 'Deep Wounds', unlocked:true).present? && @character_deep_wounds_turn == 0
                    @character_deep_wounds_turn = 3
                    @character_deep_wounds_damage = [(damage / 3).round, 0].max
                end
                # Judgement - Paladin talent
                if damage.positive? && @character.skills.find_by(name: 'Judgement', unlocked: true).present?
                    judgement_image = "<img src='/assets/paladin_skills/judgement.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    judgement = [(damage * 0.05).round, 0].max
                    @opponent_health_in_combat -= [judgement, 0].max
                    log_message += ", #{judgement_image} Judgement: <strong>#{judgement}</strong> additional true damage"
                end
            @combat_logs << log_message

            # After attack healing
            if @character_has_crit == true && @character.skills.find_by(name: 'Path of the Dead', unlocked: true).present? && damage.positive?
                path_of_the_dead_image = "<img src='/assets/deathwalker_skills/pathofthedead.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                path_of_the_dead = (damage * 0.33).round
                @character.total_health += [path_of_the_dead, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name}: #{path_of_the_dead_image} - <strong>#{path_of_the_dead}</strong> health recovery"
                @combat_logs << log_message
            end

        # Apply combat skills
        @character.apply_combat_skills

            # Dawnbreaker
            if (@opponent_health_in_combat <= (@opponent.total_max_health * 0.10)) && (@character.main_hand.present? && @character.main_hand.name == "Dawnbreaker") ||
            (@character.off_hand.present? && @character.off_hand.name == "Dawnbreaker")
                dawnbreaker_image = "<img src='/assets/legendary_items/dawnbreaker.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                    if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                        dawnbreaker_damage = (physical_damage * 1.11).round
                        damage_type = 'physical'
                    elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                        dawnbreaker_damage = (magic_damage * 1.11).round
                        damage_type = 'magic'
                    elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                        dawnbreaker_damage = (shadow_damage * 1.11).round
                        damage_type = 'shadow'
                    end
                        # Check for the statuses
                        if dawnbreaker_damage == 0
                            if @character_has_missed == true
                                log_message = "#{@character.character_name}: #{dawnbreaker_image} Dawn's Judgement - ❌ (MISS)"
                            elsif @opponent_has_evaded == true
                                log_message = "#{@character.character_name}: #{dawnbreaker_image} Dawn's Judgement - 🚫 (EVADE)"
                            end
                        else
                            if @character_has_crit == true && @opponent_has_ignored_pain == true
                                @opponent_health_in_combat -= [dawnbreaker_damage, 0].max
                                log_message = "#{@character.character_name}: #{dawnbreaker_image} Dawn's Judgement - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{dawnbreaker_damage}</strong> #{damage_type} damage"
                            elsif @character_has_crit == true
                                @opponent_health_in_combat -= [dawnbreaker_damage, 0].max
                                log_message = "#{@character.character_name}: #{dawnbreaker_image} Dawn's Judgement - ❗ (CRITICAL STRIKE) <strong>#{dawnbreaker_damage}</strong> #{damage_type} damage"
                            elsif @opponent_has_ignored_pain == true
                                @opponent_health_in_combat -= [dawnbreaker_damage, 0].max
                                log_message = "#{@character.character_name}: #{dawnbreaker_image} Dawn's Judgement - 🛡️ (IGNORE PAIN) <strong>#{dawnbreaker_damage}</strong> #{damage_type} damage"
                            else
                                @opponent_health_in_combat -= [dawnbreaker_damage, 0].max
                                log_message = "#{@character.character_name}: #{dawnbreaker_image} Dawn's Judgement - <strong>#{dawnbreaker_damage}</strong> #{damage_type} damage"
                            end
                        end
                    @combat_logs << log_message
            # Apply combat skills
            @character.apply_combat_skills
            end
            # Hellbound
            if (@character_has_crit == true && @character.skills.find_by(name: 'Skullsplitter', unlocked: true).present?) && (@character.main_hand.present? && @character.main_hand.name == "Hellbound") || (@character.off_hand.present? && @character.off_hand.name == "Hellbound")
                hellbound_skullsplitter_image = "<img src='/assets/warrior_skills/skullsplitter.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                        hellbound_skullsplitter_damage = (physical_damage * 0.70).round
                        damage_type = 'physical'
                    elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                        hellbound_skullsplitter_damage = (magic_damage * 0.70).round
                        damage_type = 'magic'
                    elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                        hellbound_skullsplitter_damage = (shadow_damage * 0.70).round
                        damage_type = 'shadow'
                    end
                        # Check for the statuses
                        if hellbound_skullsplitter_damage == 0
                            if @character_has_missed == true
                                log_message = "#{@character.character_name}: #{hellbound_skullsplitter_image} Skullsplitter - ❌ (MISS)"
                            elsif @opponent_has_evaded == true
                                log_message = "#{@character.character_name}: #{hellbound_skullsplitter_image} Skullsplitter - 🚫 (EVADE)"
                            end
                        else
                            if @character_has_crit == true && @opponent_has_ignored_pain == true
                                @opponent_health_in_combat -= [hellbound_skullsplitter_damage, 0].max
                                log_message = "#{@character.character_name}: #{hellbound_skullsplitter_image} Skullsplitter - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{hellbound_skullsplitter_damage}</strong> #{damage_type} damage"
                            elsif @character_has_crit == true
                                @opponent_health_in_combat -= [hellbound_skullsplitter_damage, 0].max
                                log_message = "#{@character.character_name}: #{hellbound_skullsplitter_image} Skullsplitter - ❗ (CRITICAL STRIKE) <strong>#{hellbound_skullsplitter_damage}</strong> #{damage_type} damage"
                            elsif @opponent_has_ignored_pain == true
                                @opponent_health_in_combat -= [hellbound_skullsplitter_damage, 0].max
                                log_message = "#{@character.character_name}: #{hellbound_skullsplitter_image} Skullsplitter - 🛡️ (IGNORE PAIN) <strong>#{hellbound_skullsplitter_damage}</strong> #{damage_type} damage"
                            else
                                @opponent_health_in_combat -= [hellbound_skullsplitter_damage, 0].max
                                log_message = "#{@character.character_name}: #{hellbound_skullsplitter_image} Skullsplitter - <strong>#{hellbound_skullsplitter_damage}</strong> #{damage_type} damage"
                            end
                        end
                    @combat_logs << log_message
            # Apply combat skills
            @character.apply_combat_skills
            end
            # Laceration
            if (@character.main_hand.present? && @character.main_hand.name == "Laceration") ||
            (@character.off_hand.present? && @character.off_hand.name == "Laceration")
                laceration_image = "<img src='/assets/legendary_items/laceration.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                        laceration_damage = (physical_damage * 0.30).round
                        damage_type = 'physical'
                    elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                        laceration_damage = (magic_damage * 0.30).round
                        damage_type = 'magic'
                    elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                        laceration_damage = (shadow_damage * 0.30).round
                        damage_type = 'shadow'
                    end
                        # Check for the statuses
                        if laceration_damage == 0
                            if @character_has_missed == true
                                log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - ❌ (MISS)"
                            elsif @opponent_has_evaded == true
                                log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - 🚫 (EVADE)"
                            end
                        else
                            if @character_has_crit == true && @opponent_has_ignored_pain == true
                                @opponent_health_in_combat -= [laceration_damage, 0].max
                                log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{laceration_damage}</strong> #{damage_type} damage"
                            elsif @character_has_crit == true
                                @opponent_health_in_combat -= [laceration_damage, 0].max
                                log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - ❗ (CRITICAL STRIKE) <strong>#{laceration_damage}</strong> #{damage_type} damage"
                            elsif @opponent_has_ignored_pain == true
                                @opponent_health_in_combat -= [laceration_damage, 0].max
                                log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - 🛡️ (IGNORE PAIN) <strong>#{laceration_damage}</strong> #{damage_type} damage"
                            else
                                @opponent_health_in_combat -= [laceration_damage, 0].max
                                log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - <strong>#{laceration_damage}</strong> #{damage_type} damage"
                            end
                        end
                    @combat_logs << log_message
            end
            # Nethil
            if (@character.main_hand.present? && @character.main_hand.name == "Nethil") ||
            (@character.off_hand.present? && @character.off_hand.name == "Nethil")
                nethil_image = "<img src='/assets/legendary_items/nethil.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                nethil_damage = 333
                @opponent_health_in_combat -= [nethil_damage, 0].max
                @character.total_health += nethil_damage
                log_message = "#{@character.character_name}: #{nethil_image} Necrotic Touch - <strong>#{nethil_damage}</strong> shadow damage, <strong>#{nethil_damage}</strong> Health recovery"
                @combat_logs << log_message
            end
            # Apply end turn effects
            if @character.skills.find_by(name: 'Deep Wounds', unlocked:true).present? && @character_deep_wounds_turn > 0
                deep_wounds_image = "<img src='/assets/warrior_skills/deepwounds.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat -= [(@character_deep_wounds_damage - (@opponent.total_armor + @opponent.buffed_armor)), 0].max
                log_message = "#{@character.character_name}: #{deep_wounds_image} Deep Wounds - <strong>#{@character_deep_wounds_damage}</strong> physical damage"
                @combat_logs << log_message
            end
            if @character.skills.find_by(name: 'Crimson Torrent', unlocked:true).present?
                crimson_torrent_image = "<img src='/assets/deathwalker_skills/crimsontorrent.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                crimson_torrent = (@character.total_max_health * 0.03).round
                @opponent_health_in_combat -= [crimson_torrent, 0].max
                log_message = "#{@character.character_name}: #{crimson_torrent_image} Crimson Torrent - <strong>#{crimson_torrent}</strong> shadow damage"
                @combat_logs << log_message
            end
            if @character.skills.find_by(name:'Lifetap', unlocked:true).present?
                lifetap_image = "<img src='/assets/deathwalker_skills/lifetap.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                lifetap = (@character.total_max_health * 0.01).round
                @character.total_health -= [lifetap, 0].max
                @character.buffed_necrosurge += lifetap
                log_message = "#{@character.character_name}: #{lifetap_image} Lifetap - sacrificed <strong>#{lifetap}</strong> Health to gain <strong>#{lifetap}</strong> Necrosurge"
                @combat_logs << log_message
            end
            if @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth == true
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                ephemeral_rebirth_damage = (@character.total_max_health * 0.10).round
                @character.total_health -= [ephemeral_rebirth_damage, 0].max
                log_message = "#{@character.character_name}: #{ephemeral_rebirth_image} Ephemeral Rebirth - lost <strong>#{ephemeral_rebirth_damage}</strong> Health"
                @combat_logs << log_message
            end

            # Cheat death skills
            if @opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Nullify', unlocked: true).present? && @opponent.nullify == false
                nullify_image = "<img src='/assets/mage_skills/nullify.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat = 1
                @opponent.nullify = true
                log_message = "#{@opponent.character_name}: #{nullify_image} Nullify triggered" if @opponent.nullify == true
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth  == false
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat = @opponent.total_max_health
                @opponent.ephemeral_rebirth = true
                log_message = "#{@opponent.character_name}: #{ephemeral_rebirth_image} Ephemeral Rebirth triggered" if @opponent.ephemeral_rebirth == true
                @combat_logs << log_message
            end

            if @opponent.is_a?(Character)
                if @opponent_health_in_combat <= 0
                    log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.character_name}: ☠ <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                elsif @character.total_health <= 0
                    log_message = "#{@character.character_name}: ☠ <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.character_name}: <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                else
                    log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.character_name}: <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                end
            elsif @opponent.is_a?(Monster)
                if @opponent_health_in_combat <= 0
                    log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.monster_name}: ☠ <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                elsif @character.total_health <= 0
                    log_message = "#{@character.character_name}: ☠ <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.monster_name}: <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                else
                    log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.monster_name}: <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                end
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
        swift_movements = 0
        damage_type = ''

        if @opponent.took_damage == true && @opponent.is_a?(Character)
            @opponent.apply_trigger_skills
            if @opponent.skills.find_by(name: 'Surge of Light', unlocked: true).present?
                surge_of_light_image = "<img src='/assets/paladin_skills/surgeoflight.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                surge_of_light = (@opponent.total_max_health * 0.02).round
                @opponent_health_in_combat += [surge_of_light, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name}: #{surge_of_light_image} Surge of Light - <strong>#{surge_of_light}</strong> Health recovery"
                @combat_logs << log_message
            end
        end
        if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Piety', unlocked: true).present? && (@opponent_health_in_combat <= (@opponent.total_max_health* 0.50 )) && @opponent.piety == false
            piety_image = "<img src='/assets/paladin_skills/piety.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            piety = (@opponent.total_max_health * 0.20).round
            @opponent_health_in_combat += [piety, @opponent.total_max_health - @opponent_health_in_combat].min
            @opponent.piety = true
            log_message = "#{@opponent.character_name}: #{piety_image} Piety - <strong>#{piety}</strong> Health recovery"
            @combat_logs << log_message
        end
        # Additional attacks
        if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Swift Movements', unlocked: true).present?
            # Pick the element of attack
            if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                swift_movements = (physical_damage * 0.5).round
                damage_type = 'physical'
            elsif @opponent_spellpower > @opponent_attack  && @opponent_spellpower > @opponent_necrosurge
                swift_movements = (magic_damage * 0.5).round
                damage_type = 'magic'
            elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                swift_movements = (shadow_damage * 0.5).round
                damage_type = 'shadow'
            end
            chance_of_additional_attack = @opponent.agility
            if rand(0.0..5000.0) <= chance_of_additional_attack
                    swift_movements_image = "<img src='/assets/rogue_skills/swiftmovements.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    # Check for the statuses of an attack
                    if swift_movements == 0
                        if @opponent_has_missed == true
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - ❌ (MISS)"
                        elsif @character_has_evaded == true
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - 🚫 (EVADE)"
                        end
                    else
                        if @opponent_has_crit == true && @character_has_ignored_pain == true
                            @character.total_health -= swift_movements
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{swift_movements}</strong> #{damage_type} damage"
                        elsif @opponent_has_crit == true
                            @character.total_health -= swift_movements
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - ❗ (CRITICAL STRIKE) <strong>#{swift_movements}</strong> #{damage_type} damage"
                        elsif @character_has_ignored_pain == true
                            @character.total_health -= swift_movements
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - 🛡️ (IGNORE PAIN) <strong>#{swift_movements}</strong> #{damage_type} damage"
                        else
                            @character.total_health -= swift_movements
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - <strong>#{swift_movements}</strong> #{damage_type} damage"
                        end
                    end
                    @opponent.apply_combat_skills if @opponent.is_a?(Character)
                    if rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                        sharpened_blade_image = "<img src='/assets/rogue_skills/sharpenedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                        sharpened_blade = (physical_damage * 0.5).round
                        @character.total_health -= [sharpened_blade, 0].max
                        log_message += ", #{sharpened_blade_image} Sharpened Blade - <strong>#{sharpened_blade}</strong> additional physical damage"
                    elsif rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                        poisoned_blade_image = "<img src='/assets/rogue_skills/poisonedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                        poisoned_blade = (magic_damage * 0.5).round
                        @character.total_health -= [poisoned_blade, 0].max
                        log_message += ", #{poisoned_blade_image} Poisoned Blade - <strong>#{poisoned_blade}</strong> additional magic damage"
                    end
                    if swift_movements.positive? && @opponent_has_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                        from_the_shadows_image = "<img src='/assets/rogue_skills/fromtheshadows.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                        from_the_shadows = (swift_movements * 0.25).round
                        @character.total_health -= [from_the_shadows, 0].max
                        log_message += ", #{from_the_shadows_image} From the Shadows - <strong>#{from_the_shadows}</strong> additional true damage"
                    end
                @combat_logs << log_message
            end
        end

        # Normal attack
        # Pick the element of attack
        if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
            damage = [physical_damage, 0].max
            damage_type = 'physical'
        elsif @opponent_spellpower > @opponent_attack  && @opponent_spellpower > @opponent_necrosurge
            damage = [magic_damage, 0].max
            damage_type = 'magic'
        elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
            damage = [shadow_damage, 0].max
            damage_type = 'shadow'
        end
            # Check statuses of an attack
            if @opponent.is_a?(Character)
                if damage == 0
                    if @opponent_has_missed == true
                        log_message = "#{@opponent.character_name}: ⚔️ Basic attack - ❌ (MISS)"
                    elsif @character_has_evaded == true
                        log_message = "#{@opponent.character_name}: ⚔️ Basic attack - 🚫 (EVADE)"
                    end
                else
                    if @opponent_has_crit == true && @character_has_ignored_pain == true
                        @character.total_health -= damage
                        log_message = "#{@opponent.character_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                    elsif @opponent_has_crit == true
                        @character.total_health -= damage
                        log_message = "#{@opponent.character_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                    elsif @character_has_ignored_pain == true
                        @character.total_health -= damage
                        log_message = "#{@opponent.character_name}: ⚔️ Basic attack - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                    else
                        @character.total_health -= damage
                        log_message = "#{@opponent.character_name}: ⚔️ Basic attack - <strong>#{damage}</strong> #{damage_type} damage"
                    end
                end
            elsif @opponent.is_a?(Monster)
                if damage == 0
                    if @opponent_has_missed == true
                        log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - ❌ (MISS)"
                    elsif @character_has_evaded == true
                        log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - 🚫 (EVADE)"
                    end
                else
                    if @opponent_has_crit == true && @character_has_ignored_pain == true
                        @character.total_health -= damage
                        log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                    elsif @opponent_has_crit == true
                        @character.total_health -= damage
                        log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                    elsif @character_has_ignored_pain == true
                        @character.total_health -= damage
                        log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                    else
                        @character.total_health -= damage
                        log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - <strong>#{damage}</strong> #{damage_type} damage"
                    end
                end
            end
        # Apply combat skills
        @opponent.apply_combat_skills if @opponent.is_a?(Character)
            # Additional damage
            if rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                sharpened_blade_image = "<img src='/assets/rogue_skills/sharpenedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                sharpened_blade = (physical_damage * 0.5).round
                @character.total_health -= [sharpened_blade, 0].max
                log_message += ", #{sharpened_blade_image} Sharpened Blade - <strong>#{sharpened_blade}</strong> additional physical damage"
            elsif rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                poisoned_blade_image = "<img src='/assets/rogue_skills/poisonedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                poisoned_blade = (magic_damage * 0.5).round
                @character.total_health -= [poisoned_blade, 0].max
                log_message += ", #{poisoned_blade_image} Poisened Blade - <strong>#{poisoned_blade}</strong> additional magic damage"
            end
            if damage.positive? && @opponent_has_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                from_the_shadows_image = "<img src='/assets/rogue_skills/fromtheshadows.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                from_the_shadows = (damage * 0.25).round
                @character.total_health -= [from_the_shadows, 0].max
                log_message += ", #{from_the_shadows_image} From the Shadows - <strong>#{from_the_shadows}</strong> additional true damage"
            end
            if damage.positive? && @opponent_has_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Skullsplitter', unlocked: true).present? && !(@opponent.main_hand.name == 'Hellbound' || @opponent.off_hand.name == 'Hellbound')
                skullsplitter_image = "<img src='/assets/warrior_skills/skullsplitter.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                skullsplitter = (@character.total_max_health * 0.06).round
                @character.total_health -= [skullsplitter, 0].max
                log_message += ", #{skullsplitter_image} Skullsplitter - <strong>#{skullsplitter}</strong> additional true damage"
            end
            if damage.positive? && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Deep Wounds', unlocked:true).present? && @opponent_deep_wounds_turn == 0
                @opponent_deep_wounds_turn = 3
                @opponent_deep_wounds_damage = (damage / 3).round
            end
            if damage.positive? && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Judgement', unlocked: true).present?
                judgement_image = "<img src='/assets/paladin_skills/judgement.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                judgement = (damage * 0.05).round
                @character.total_health -= [judgement, 0].max
                log_message += ", #{judgement_image} Judgement - <strong>#{judgement}</strong> additional true damage"
            end
        @combat_logs << log_message
            # After attack healing
            if damage.positive? && @opponent_has_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Path of the Dead', unlocked: true).present?
                path_of_the_dead_image = "<img src='/assets/deathwalker_skills/pathofthedead.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                path_of_the_dead = (damage * 0.33).round
                @opponent_health_in_combat += [path_of_the_dead, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name}: #{path_of_the_dead_image} Path of the Dead - <strong>#{path_of_the_dead}</strong> Health recovery"
                @combat_logs << log_message
            end
            # End of turn effects
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Deep Wounds', unlocked:true).present? && @opponent_deep_wounds_turn > 0
                deep_wounds_image = "<img src='/assets/warrior_skills/deepwounds.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health -= [(@opponent_deep_wounds_damage - (@character.total_armor + @character.buffed_armor)), 0].max
                log_message = "#{@opponent.character_name}: #{deep_wounds_image} Deep Wounds - <strong>#{@opponent_deep_wounds_damage}</strong> physical damage"
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Crimson Torrent', unlocked:true).present?
                crimson_torrent_image = "<img src='/assets/deathwalker_skills/crimsontorrent.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                crimson_torrent = (@opponent.total_max_health * 0.03).round
                @character.total_health -= [crimson_torrent, 0].max
                log_message = "#{@opponent.character_name}: #{crimson_torrent_image} Crimson Torrent - <strong>#{crimson_torrent}</strong> shadow damage"
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name:'Lifetap', unlocked:true).present?
                lifetap_image = "<img src='/assets/deathwalker_skills/lifetap.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                lifetap = (@opponent.total_max_health * 0.01).round
                @opponent_health_in_combat -= [lifetap, 0].max
                @opponent.buffed_necrosurge += lifetap
                log_message = "#{@opponent.character_name}: #{lifetap_image} Lifetap - sacrificed <strong>#{lifetap}</strong> Health to gain <strong>#{lifetap}</strong> Necrosurge"
                @combat_logs << log_message
            end
            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth == true
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                ephemeral_rebirth_damage = (@opponent.total_max_health * 0.10).round
                @opponent_health_in_combat -= [ephemeral_rebirth_damage, 0].max
                log_message = "#{@opponent.character_name}: #{ephemeral_rebirth_image} Ephemeral Rebirth - lost <strong>#{ephemeral_rebirth_damage}</strong> Health"
                @combat_logs << log_message
            end
        # Cheat death effects
        if @character.total_health <= 0 && @character.skills.find_by(name: 'Nullify', unlocked: true).present? && @character.nullify == false
            nullify_image = "<img src='/assets/mage_skills/nullify.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            @character.total_health = 1
            @character.nullify = true
            log_message = "#{@character.character_name}: #{nullify_image} Nullify triggered" if @character.nullify == true
            @combat_logs << log_message
        end
        if @character.total_health <= 0 && @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth  == false
            ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            @character.total_health = @character.total_max_health
            @character.ephemeral_rebirth = true
            log_message = "#{@character.character_name}: #{ephemeral_rebirth_image} Ephemeral Rebirth triggered " if @character.ephemeral_rebirth == true
            @combat_logs << log_message
        end
            # Log the health values at the end of the turn
            if @opponent.is_a?(Character)
                if @opponent_health_in_combat <= 0
                    log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.character_name}: ☠ <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                elsif @character.total_health <= 0
                    log_message = "#{@character.character_name}: ☠ <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.character_name}: <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                else
                    log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.character_name}: <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                end
            elsif @opponent.is_a?(Monster)
                if @opponent_health_in_combat <= 0
                    log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.monster_name}: ☠ <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                elsif @character.total_health <= 0
                    log_message = "#{@character.character_name}: ☠ <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.monster_name}: <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                else
                    log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\">#{@character.total_health} / #{@character.total_max_health}</span> Health"
                    @combat_logs << log_message
                    log_message = "#{@opponent.monster_name}: <span style=\"text-decoration: underline;\">#{@opponent_health_in_combat} / #{@opponent.total_max_health}</span> Health"
                    @combat_logs << log_message
                end
            end

        @character.total_health = [0, @character.total_health].max
        @character.took_damage = true if damage.positive?
        @opponent.took_damage = false
    end

end
