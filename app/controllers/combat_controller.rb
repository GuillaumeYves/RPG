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
        @character.blessing_of_kings = false
        @opponent.blessing_of_kings = false if @opponent.is_a?(Character)
        @character.deathsbargain = false
        @opponent.deathsbargain = false if @opponent.is_a?(Character)
        @character.took_damage = false
        @opponent.took_damage = false if @opponent.is_a?(Character)
        @opponent_health_in_combat = @opponent.total_health.to_i
        @character_deep_wounds_turn = 0
        @opponent_deep_wounds_turn = 0
        @character_blessing_of_kings_turn = 0
        @opponent_blessing_of_kings_turn = 0
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
            respond_to do |format|
                format.js { render js: "window.location.reload()" }
            end
            return
        end

        # Initialize combat
        initialize_combat_variables

        # Default values for buffs
        reset_buffed_stats

        # Randomly determine the first turn
        @character_turn = rand(2).zero?
        @opponent_turn = !@character_turn

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
                damage_roll = (@character.total_max_attack + @character.buffed_max_attack)
            else
                damage_roll = rand((@character.total_min_attack + @character.buffed_min_attack)..(@character.total_max_attack + @character.buffed_max_attack))
            end
            # Check for a miss with Forged in Battle
            if @character.skills.find_by(name: 'Forged in Battle', unlocked: true).present? && rand(0.00..100.00) <= 20.00
                damage = 0
                @character_has_missed = true
            else
                if (@character.feet.present? && @character.feet.name == "Voidwalkers")
                    # Chance to evade damage
                    if rand(0.00..100.00) <= @opponent.evasion
                        unless @character.skills.find_by(name: 'Undeniable', unlocked: true).present?
                            damage = 0
                            @opponent_has_evaded = true
                        end
                    else
                        # Check for a critical hit based on critical_strike_chance
                        if rand(0.00..100.00) <= (@character.total_critical_strike_chance + @character.buffed_critical_strike_chance)
                            damage =  ((damage_roll + (damage_roll * @character.total_global_damage)) + (damage_roll * (@character.total_critical_strike_damage + @character.buffed_critical_strike_damage)))
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
                    end
                    # Apply blessing of kings reduction if active
                    if (@opponent.is_a?(Character) && @opponent.blessing_of_kings == true) && @opponent_blessing_of_kings_turn > 0
                        [(damage * 0.85).round, 0].max
                    end
                    return damage.round
                else
                    # Chance to evade damage
                    if rand(0.00..100.00) <= @opponent.evasion
                        unless @character.skills.find_by(name: 'Undeniable', unlocked: true).present?
                            damage = 0
                            @opponent_has_evaded = true
                        end
                    else
                        # Check for a critical hit based on critical_strike_chance
                        if rand(0.00..100.00) <= (@character.total_critical_strike_chance + @character.buffed_critical_strike_chance)
                            damage =  (((damage_roll + (damage_roll * @character.total_global_damage)) + (damage_roll * (@character.total_critical_strike_damage + @character.buffed_critical_strike_damage))) - (@opponent.total_armor + @opponent.buffed_armor))
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
                    end
                    # Apply blessing of kings reduction if active
                    if (@opponent.is_a?(Character) && @opponent.blessing_of_kings == true) && @opponent_blessing_of_kings_turn > 0
                        [(damage * 0.85).round, 0].max
                    end
                    return damage.round
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
                if @opponent.is_a?(Character) && (@opponent.feet.present? && @opponent.feet.name == "Voidwalkers")
                    # Chance to evade damage
                    if rand(0.00..100.00) <= @character.evasion
                        unless @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Undeniable', unlocked: true).present?
                            damage = 0
                            @character_has_evaded = true
                        end
                    else
                        # Check for a critical hit based on critical_strike_chance
                        if rand(0.00..100.00) <= (@opponent.total_critical_strike_chance + @opponent.buffed_critical_strike_chance)
                            damage =  ((damage_roll + (damage_roll * @opponent.total_global_damage)) + (damage_roll * (@opponent.total_critical_strike_damage + @opponent.buffed_critical_strike_damage)))
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
                else
                    # Chance to evade damage
                    if rand(0.00..100.00) <= @character.evasion
                        unless @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Undeniable', unlocked: true).present?
                            damage = 0
                            @character_has_evaded = true
                        end
                    else
                        # Check for a critical hit based on critical_strike_chance
                        if rand(0.00..100.00) <= (@opponent.total_critical_strike_chance + @opponent.buffed_critical_strike_chance)
                            damage =  (((damage_roll + (damage_roll * @opponent.total_global_damage)) + (damage_roll * (@opponent.total_critical_strike_damage + @opponent.buffed_critical_strike_damage))) - (@character.total_armor + @character.buffed_armor))
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
        end
        if @opponent.is_a?(Character) && @opponent.main_hand.present? && @opponent.main_hand.name == "Nemesis" && @character.total_health >= (@character.total_max_health * 0.70)
            [(damage * 1.5).round, 0].max # Return damage with Nemesis
        end
        # Apply blessing of kings reduction if active
        if @character.blessing_of_kings == true && @character_blessing_of_kings_turn > 0
            [(damage * 0.85).round, 0].max
        end
        return damage.round
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
                    damage =  (((damage_roll + (damage_roll * @character.total_global_damage)) + (damage_roll * (@character.total_critical_strike_damage + @character.buffed_critical_strike_damage))) - (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance))
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
                end
                # Apply blessing of kings reduction if active
                if (@opponent.is_a?(Character) && @opponent.blessing_of_kings == true) && @opponent_blessing_of_kings_turn > 0
                    [(damage * 0.85).round, 0].max
                end
                return damage.round
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
                    damage =  (((damage_roll + (damage_roll * @opponent.total_global_damage)) + (damage_roll * (@opponent.total_critical_strike_damage + @opponent.buffed_critical_strike_damage))) - (@character.total_magic_resistance + @character.buffed_magic_resistance))
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
        end
        # Apply blessing of kings reduction if active
        if (@character.blessing_of_kings == true && @character_blessing_of_kings_turn > 0)
            [(damage * 0.85).round, 0].max
        end
        return damage.round
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
                    unless @character.skills.find_by(name: 'Undeniable', unlocked: true).present?
                        damage = 0
                        @opponent_has_evaded = true
                    end
                else
                    # Check for a critical hit based on critical_strike_chance
                    if rand(0.00..100.00) <= (@character.total_critical_strike_chance + @character.buffed_critical_strike_chance)
                        damage =  ((damage_roll + (damage_roll * @character.total_global_damage) + (damage_roll * (@character.total_critical_strike_damage + @character.buffed_critical_strike_damage))))
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
                end
                # Apply blessing of kings reduction if active
                if (@opponent.is_a?(Character) && @opponent.blessing_of_kings == true) && @opponent_blessing_of_kings_turn > 0
                    [(damage * 0.85).round, 0].max
                end
                return damage.round
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
                    unless @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Undeniable', unlocked: true).present?
                        damage = 0
                        @character_has_evaded = true
                    end
                else
                    # Check for a critical hit based on critical_strike_chance
                    if rand(0.00..100.00) <= (@opponent.total_critical_strike_chance + @opponent.buffed_critical_strike_chance)
                        damage =  ((damage_roll + (damage_roll * @opponent.total_global_damage) + (damage_roll * (@opponent.total_critical_strike_damage + @opponent.buffed_critical_strike_damage))))
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
        end
        # Apply blessing of kings reduction if active
        if @character.blessing_of_kings == true && @character_blessing_of_kings_turn > 0
            [(damage * 0.85).round, 0].max
        end
        return damage.round
    end

    def damage_after_attack(damage)
        additional_damage = 0
        # Character turn
        if @character_turn
############# After attack talents
            # Sharpened Blade - Nightstalker talent
            if rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                sharpened_blade_image = "<img src='/assets/nightstalker_skills/sharpenedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [((damage * 0.8).round - (@opponent.total_armor + @opponent.buffed_armor)), 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                if additional_damage.positive?
                    log_message = "#{@character.character_name}: #{@sharpened_blade_image} Sharpened Blade - <strong>#{additional_damage}</strong> additional physical damage"
                end
                @combat_logs << log_message
            # Poisened Blade - Nightstalker talent
            elsif rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                poisoned_blade_image = "<img src='/assets/nightstalker_skills/poisonedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [((damage * 0.8).round - (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance)), 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                if additional_damage.positive?
                    log_message = "#{@character.character_name}: #{@poisoned_blade_image} Poisoned Blade - <strong>#{additional_damage}</strong> additional magic damage"
                end
                @combat_logs << log_message
            end
            # From the Shadows - Nightstalker talent
            if @character_has_crit == true && @character.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                from_the_shadows_image = "<img src='/assets/nightstalker_skills/fromtheshadows.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [(damage * 0.25).round, 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_message = "#{@character.character_name}: #{@from_the_shadows_image} From the Shadows - <strong>#{additional_damage}</strong> additional true damage"
                @combat_logs << log_message
            end
            # Skullsplitter - Warrior talent
            if @character_has_crit == true && @character.skills.find_by(name: 'Skullsplitter', unlocked: true).present?
                skullsplitter_image = "<img src='/assets/warrior_skills/skullsplitter.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [((@opponent.total_max_health * 0.10).round - (@opponent.total_armor + @opponent.buffed_armor)), 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_message = "#{@character.character_name}: #{@skullsplitter_image} Skullsplitter - <strong>#{additional_damage}</strong> additional physical damage"
                @combat_logs << log_message
            end
            # Deep Wounds - Warrior talent initialize
            if @character.skills.find_by(name: 'Deep Wounds', unlocked:true).present? && @character_deep_wounds_turn == 0
                @character_deep_wounds_turn = 3
                @character_deep_wounds_damage = [(damage / 3).round, 0].max
            end
            # Judgement - Paladin talent
            if @character.skills.find_by(name: 'Judgement', unlocked: true).present?
                judgement_image = "<img src='/assets/paladin_skills/judgement.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [(damage * 0.05).round, 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_message = "#{@character.character_name}: #{judgement_image} Judgement - <strong>#{additional_damage}</strong> additional true damage"
                @combat_logs << log_message
            end
############# After attack items
            # Pandemonium
            if @character_has_crit == true && (@character.chest.present? && @character.chest.name == "Pandemonium")
                pandemonium_image = "<img src='/assets/legendary_items/pandemonium.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                additional_damage = [(damage * 0.22).round, 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_message = "#{@character.character_name}: #{pandemonium_image} Inferno Heart - <strong>#{additional_damage}</strong> additional fire damage"
                @combat_logs << log_message
            end
            # Ruler of Storms
            if (@character.main_hand.present? && @character.main_hand.name == "Ruler of Storms") || (@character.off_hand.present? && @character.off_hand.name == "Ruler of Storms")
                rulerofstorms_image = "<img src='/assets/legendary_items/rulerofstorms.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                additional_damage = [(((damage * 0.4).round) - (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance)), 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_message = "#{@character.character_name}: #{rulerofstorms_image} Sentence of the Skies - <strong>#{additional_damage}</strong> additional magic damage"
                @combat_logs << log_message
            end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if additional_damage.positive?
        # Opponent turn
        elsif @opponent_turn && @opponent.is_a?(Character)
############# After attack talents
            # Sharpened Blade - Nightstalker talent
            if rand(0.0..100.0) <= 30.0 && @opponent.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                sharpened_blade_image = "<img src='/assets/nightstalker_skills/sharpenedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [((damage * 0.8).round - (@character.total_armor + @character.buffed_armor)), 0].max
                @character.total_health -= [additional_damage, 0].max
                log_message = "#{@opponent.character_name}: #{sharpened_blade_image} Sharpened Blade - <strong>#{additional_damage}</strong> additional physical damage"
                @combat_logs << log_message
                # Poisened Blade - Nightstalker talent
            elsif rand(0.0..100.0) <= 30.0 && @opponent.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                poisoned_blade_image = "<img src='/assets/nightstalker_skills/poisonedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [((damage * 0.8).round - (@character.total_magic_resistance + @character.buffed_magic_resistance)), 0].max
                @character.total_health -= [additional_damage, 0].max
                log_message = "#{@opponent.character_name}: #{poisoned_blade_image} Poisoned Blade - <strong>#{additional_damage}</strong> additional magic damage"
                @combat_logs << log_message
            end
            # From the Shadows - Nightstalker talent
            if @opponent_has_crit == true && @opponent.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                from_the_shadows_image = "<img src='/assets/nightstalker_skills/fromtheshadows.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [(damage * 0.25).round, 0].max
                @character.total_health -= [additional_damage, 0].max
                log_message = "#{@opponent.character_name}: #{from_the_shadows_image} From the Shadows - <strong>#{additional_damage}</strong> additional true damage"
                @combat_logs << log_message
            end
            # Skullsplitter - Warrior talent
            if @opponent_has_crit == true && @opponent.skills.find_by(name: 'Skullsplitter', unlocked: true).present?
                skullsplitter_image = "<img src='/assets/warrior_skills/skullsplitter.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [((@character.total_max_health * 0.10).round - (@character.total_armor + @character.buffed_armor)), 0].max
                @character.total_health -= [additional_damage, 0].max
                log_message = "#{@opponent.character_name}: #{skullsplitter_image} Skullsplitter - <strong>#{additional_damage}</strong> additional physical damage"
                @combat_logs << log_message
            end
            # Deep Wounds - Warrior talent
            if @opponent.skills.find_by(name: 'Deep Wounds', unlocked:true).present? && @opponent_deep_wounds_turn == 0
                @opponent_deep_wounds_turn = 3
                @opponent_deep_wounds_damage = [(damage / 3).round, 0].max
            end
            # Judgement - Paladin talent
            if @opponent.skills.find_by(name: 'Judgement', unlocked: true).present?
                judgement_image = "<img src='/assets/paladin_skills/judgement.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                additional_damage = [(damage * 0.05).round, 0].max
                @character.total_health -= [additional_damage, 0].max
                log_message = "#{@opponent.character_name}: #{judgement_image} Judgement - <strong>#{additional_damage}</strong> additional true damage"
                @combat_logs << log_message
            end
############# After attack items
            # Pandemonium
            if @opponent_has_crit == true && @opponent.is_a?(Character) && (@opponent.chest.present? && @opponent.chest.name == "Pandemonium")
                pandemonium_image = "<img src='/assets/legendary_items/pandemonium.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                additional_damage = [(damage * 0.22).round, 0].max
                @character.total_health -= [additional_damage, 0].max
                log_message = "#{@opponent.character_name}: #{pandemonium_image} Inferno Heart - <strong>#{additional_damage}</strong> additional fire damage"
                @combat_logs << log_message
            end
            # Ruler of Storms
            if (@opponent.main_hand.present? && @opponent.main_hand.name == "Ruler of Storms") || (@opponent.off_hand.present? && @opponent.off_hand.name == "Ruler of Storms")
                rulerofstorms_image = "<img src='/assets/legendary_items/rulerofstorms.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                additional_damage = [((damage * 0.4).round), 0].max
                @character.total_health -= [additional_damage, 0].max
                log_message = "#{@opponent.character_name}: #{rulerofstorms_image} Sentence of the Skies - <strong>#{additional_damage}</strong> additional magic damage"
                @combat_logs << log_message
            end
        end
        # Character took damage is now true if damage is positive
        @character.took_damage = true if additional_damage.positive?
    end

    def buffs_after_attack
        # Character turn
        if @character_turn
############# Buffs from items
            # Helion
            if @character_has_crit == true && (@character.main_hand.present? && @character.main_hand.name == "Helion") || (@character.off_hand.present? && @character.off_hand.name == "Helion")
                helion_image = "<img src='/assets/legendary_items/helion.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Helion' class='log-skill-image'>"
                @character.buffed_min_spellpower += (@character.min_spellpower * 0.20)
                @character.buffed_max_spellpower += (@character.max_spellpower * 0.20)
                log_message = "#{@character.character_name}: #{helion_image} Helion - ⬆️ Spellpower increased by <strong>20%</strong>"
                @combat_logs << log_message
            end
            # Eternal Rage
            if (@character.head.present? && @character.head.name == "Eternal Rage")
                eternal_rage_image = "<img src='/assets/legendary_items/eternalrage.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Helion' class='log-skill-image'>"
                @character.buffed_min_attack += (@character.min_attack * 0.15)
                @character.buffed_max_attack += (@character.max_attack * 0.15)
                log_message = "#{@character.character_name}: #{eternal_rage_image} Eternal Rage - ⬆️ Attack increased by <strong>15%</strong>"
                @combat_logs << log_message
            end
        # Opponent turn
        elsif @opponent_turn && @opponent.is_a?(Character)
############# Buffs from items
            # Helion
            if @opponent_has_crit == true && (@opponent.main_hand.present? && @opponent.main_hand.name == "Helion") || (@opponent.off_hand.present? && @opponent.off_hand.name == "Helion")
                helion_image = "<img src='/assets/legendary_items/helion.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Helion' class='log-skill-image'>"
                @opponent.buffed_min_spellpower += (@opponent.min_spellpower * 0.20)
                @opponent.buffed_max_spellpower += (@opponent.max_spellpower * 0.20)
                log_message = "#{@opponent.character_name}: #{helion_image} Helion - ⬆️ Spellpower increased by <strong>20%</strong>"
                @combat_logs << log_message
            end
            # Eternal Rage
            if (@opponent.head.present? && @opponent.head.name == "Eternal Rage")
                eternal_rage_image = "<img src='/assets/legendary_items/eternalrage.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Helion' class='log-skill-image'>"
                @opponent.buffed_min_attack += (@opponent.min_attack * 0.15)
                @opponent.buffed_max_attack += (@opponent.max_attack * 0.15)
                log_message = "#{@opponent.character_name}: #{eternal_rage_image} Eternal Rage - ⬆️ Attack increased by <strong>15%</strong>"
                @combat_logs << log_message
            end
        end
    end

    def healing_after_attack(damage)
        if @character_turn
            # After attack healing talents
            # Path of the Dead - Deathwalker talent
            if @character_has_crit == true && @character.skills.find_by(name: 'Path of the Dead', unlocked: true).present?
                path_of_the_dead_image = "<img src='/assets/deathwalker_skills/pathofthedead.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                path_of_the_dead = (damage * 0.33).round
                @character.total_health += [path_of_the_dead, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name}: #{path_of_the_dead_image} Path of the Dead - <strong>#{path_of_the_dead}</strong> health recovery"
                @combat_logs << log_message
            end
            # After attack healing items
            # Well of Souls
            if @character_has_crit == true && (@character.waist.present? && @character.waist.name == "Well of Souls")
                well_of_souls_image = "<img src='/assets/legendary_items/wellofsouls.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                well_of_souls_damage = (@character.total_max_health * 0.06).round
                @character.total_health += [well_of_souls_damage, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name}: #{well_of_souls_image} Life Drinker - <strong>#{well_of_souls_damage}</strong> health recovery"
                @combat_logs << log_message
            end
        elsif @opponent_turn && @opponent.is_a?(Character)
            # After attack healing talents
            # Path of the Dead - Deathwalker talent
            if @opponent_has_crit == true && @opponent.skills.find_by(name: 'Path of the Dead', unlocked: true).present?
                path_of_the_dead_image = "<img src='/assets/deathwalker_skills/pathofthedead.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                path_of_the_dead = (damage * 0.33).round
                @opponent_health_in_combat += [path_of_the_dead, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name}: #{path_of_the_dead_image} Path of the Dead - <strong>#{path_of_the_dead}</strong> health recovery"
                @combat_logs << log_message
            end
            # After attack healing items
            # Well of Souls
            if @opponent_has_crit == true && (@opponent.waist.present? && @opponent.waist.name == "Well of Souls")
                well_of_souls_image = "<img src='/assets/legendary_items/wellofsouls.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                well_of_souls_damage = (@opponent.total_max_health * 0.06).round
                @opponent_health_in_combat += [well_of_souls_damage, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name}: #{well_of_souls_image} Life Drinker - <strong>#{well_of_souls_damage}</strong> health recovery"
                @combat_logs << log_message
            end
        end
    end

    def basic_attacks
        damage = 0
        damage_type = ''
        if @character_turn
            if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                if (@character.feet.present? && @character.feet.name == "Voidwalkers")
                    damage = [physical_damage, 0].max
                    damage_type = 'shadow'
                else
                    damage = [physical_damage, 0].max
                    damage_type = 'physical'
                end
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
                        log_message = "#{@character.character_name}: ⚔️ Basic attack - Damage mitigated"
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
            @character.apply_combat_skills
            @combat_logs << log_message
            healing_after_attack(damage)
            damage_after_attack(damage)
            buffs_after_attack
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if damage.positive?
        elsif @opponent_turn
            if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                if @opponent.is_a?(Character) && (@opponent.feet.present? && @opponent.feet.name == "Voidwalkers")
                    damage = [physical_damage, 0].max
                    damage_type = 'shadow'
                else
                    damage = [physical_damage, 0].max
                    damage_type = 'physical'
                end
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
                        else
                            log_message = "#{@opponent.character_name}: ⚔️ Basic attack - Damage mitigated"
                        end
                    else
                        if @opponent_has_crit == true && @character_has_ignored_pain == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @opponent_has_crit == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @character_has_ignored_pain == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: ⚔️ Basic attack - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        else
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: ⚔️ Basic attack - <strong>#{damage}</strong> #{damage_type} damage"
                        end
                    end
                elsif @opponent.is_a?(Monster)
                    if damage == 0
                        if @opponent_has_missed == true
                            log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - ❌ (MISS)"
                        elsif @character_has_evaded == true
                            log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - 🚫 (EVADE)"
                        else
                            log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - Damage mitigated"
                        end
                    else
                        if @opponent_has_crit == true && @character_has_ignored_pain == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @opponent_has_crit == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @character_has_ignored_pain == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        else
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.monster_name}: ⚔️ Basic attack - <strong>#{damage}</strong> #{damage_type} damage"
                        end
                    end
                end
            if @opponent.is_a?(Character)
                @opponent.apply_combat_skills
            end
            @combat_logs << log_message
            healing_after_attack(damage)
            buffs_after_attack
            damage_after_attack(damage)
        # Character took damage is now true if damage is positive
        @character.took_damage = true if damage.positive?
        end
    end

    def additional_attacks
        damage = 0
        damage_type = ''

        # Character turn
        if @character_turn
            # Additional attack talents
            # Fervor - Paladin talent
            if rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Fervor', unlocked: true).present?
                fervor_image = "<img src='/assets/paladin_skills/fervor.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    if (@character.feet.present? && @character.feet.name == "Voidwalkers")
                        damage = [(physical_damage * 0.80).round, 0].max
                        damage_type = 'shadow'
                    else
                        damage = [(physical_damage * 0.80).round, 0].max
                        damage_type = 'physical'
                    end
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    damage = (magic_damage * 0.80).round
                    damage_type = 'magic'
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    damage = (shadow_damage * 0.80).round
                    damage_type = 'shadow'
                end
                    # Check for the statuses
                    if damage == 0
                        if @character_has_missed == true
                            log_message = "#{@character.character_name}: #{fervor_image} Fervor - ❌ (MISS)"
                        elsif @opponent_has_evaded == true
                            log_message = "#{@character.character_name}: #{fervor_image} Fervor - 🚫 (EVADE)"
                        else
                            log_message = "#{@character.character_name}: #{fervor_image} Fervor - Damage mitigated"
                        end
                    else
                        if @character_has_crit == true && @opponent_has_ignored_pain == true
                            @opponent_health_in_combat -= [damage, 0].max
                            log_message = "#{@character.character_name}: #{fervor_image} Fervor - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @character_has_crit == true
                            @opponent_health_in_combat -= [damage, 0].max
                            log_message = "#{@character.character_name}: #{fervor_image} Fervor - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @opponent_has_ignored_pain == true
                            @opponent_health_in_combat -= [damage, 0].max
                            log_message = "#{@character.character_name}: #{fervor_image} Fervor - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        else
                            @opponent_health_in_combat -= [damage, 0].max
                            log_message = "#{@character.character_name}: #{fervor_image} Fervor - <strong>#{damage}</strong> #{damage_type} damage"
                        end
                    end
                @character.apply_combat_skills
                @combat_logs << log_message
                healing_after_attack(damage)
                buffs_after_attack
                damage_after_attack(damage)
            end
            # Swift movements - Nightstalker talent
            if @character.skills.find_by(name: 'Swift Movements', unlocked: true).present?
                # Picks the element of attack
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    if (@character.feet.present? && @character.feet.name == "Voidwalkers")
                        damage = [(physical_damage * 0.50).round, 0].max
                        damage_type = 'shadow'
                    else
                        damage = [(physical_damage * 0.50).round, 0].max
                        damage_type = 'physical'
                    end
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    damage = (magic_damage * 0.5).round
                    damage_type = 'magic'
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    damage = (shadow_damage * 0.5).round
                    damage_type = 'shadow'
                end
                chance_of_additional_attack = @character.agility
                if rand(0.0..5000.0) <= chance_of_additional_attack
                    swift_movements_image = "<img src='/assets/nightstalker_skills/swiftmovements.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    # Check for the statuses of an attack
                    if damage == 0
                        if @character_has_missed == true
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - ❌ (MISS)"
                        elsif @opponent_has_evaded == true
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - 🚫 (EVADE)"
                        else
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - Damage mitigated"
                        end
                    else
                        if @character_has_crit == true && @opponent_has_ignored_pain == true
                            @opponent_health_in_combat -= [damage, 0].max
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @character_has_crit == true
                            @opponent_health_in_combat -= [damage, 0].max
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @opponent_has_ignored_pain == true
                            @opponent_health_in_combat -= [damage, 0].max
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        else
                            @opponent_health_in_combat -= [damage, 0].max
                            log_message = "#{@character.character_name}: #{swift_movements_image} Swift Movements - <strong>#{damage}</strong> #{damage_type} damage"
                        end
                    end
                @character.apply_combat_skills
                @combat_logs << log_message
                healing_after_attack(damage)
                buffs_after_attack
                damage_after_attack(damage)
                end
                # Additional attack items
                # Hellbound
                if (rand(0..100) <= 10) && (@character.main_hand.present? && @character.main_hand.name == "Hellbound") || (@character.off_hand.present? && @character.off_hand.name == "Hellbound")
                    hellbound_image = "<img src='/assets/images/legendary_items/hellbound.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                        if (@character.feet.present? && @character.feet.name == "Voidwalkers")
                            damage = [(physical_damage * 1.5).round, 0].max
                            damage_type = 'shadow'
                        else
                            damage = [(physical_damage * 1.5).round, 0].max
                            damage_type = 'physical'
                        end
                    elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                        damage = (magic_damage * 1.5).round
                        damage_type = 'magic'
                    elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                        damage = (shadow_damage * 1.5).round
                        damage_type = 'shadow'
                    end
                        # Check for the statuses
                        if damage == 0
                            if @character_has_missed == true
                                log_message = "#{@character.character_name}: #{hellbound_image} Hellbound - ❌ (MISS)"
                            elsif @opponent_has_evaded == true
                                log_message = "#{@character.character_name}: #{hellbound_image} Hellbound - 🚫 (EVADE)"
                            else
                                log_message = "#{@character.character_name}: #{hellbound_image} Hellbound - Damage mitigated"
                            end
                        else
                            if @character_has_crit == true && @opponent_has_ignored_pain == true
                                @opponent_health_in_combat -= [damage, 0].max
                                log_message = "#{@character.character_name}: #{hellbound_image} Hellbound - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                            elsif @character_has_crit == true
                                @opponent_health_in_combat -= [damage, 0].max
                                log_message = "#{@character.character_name}: #{hellbound_image} Hellbound - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                            elsif @opponent_has_ignored_pain == true
                                @opponent_health_in_combat -= [damage, 0].max
                                log_message = "#{@character.character_name}: #{hellbound_image} Hellbound - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                            else
                                @opponent_health_in_combat -= [damage, 0].max
                                log_message = "#{@character.character_name}: #{hellbound_image} Hellbound - <strong>#{damage}</strong> #{damage_type} damage"
                            end
                        end
                    @character.apply_combat_skills
                    @combat_logs << log_message
                    healing_after_attack(damage)
                    buffs_after_attack
                    damage_after_attack(damage)
                end
            end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if damage.positive?
        # Opponent turn
        elsif (@opponent_turn && @opponent.is_a?(Character))
            # Additional attack talents
            # Fervor - Paladin talent
            if rand(0.0..100.0) <= 30.0 && @opponent.skills.find_by(name: 'Fervor', unlocked: true).present?
                fervor_image = "<img src='/assets/paladin_skills/fervor.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                    if @opponent.is_a?(Character) && (@opponent.feet.present? && @opponent.feet.name == "Voidwalkers")
                        damage = [(physical_damage * 0.80).round, 0].max
                        damage_type = 'shadow'
                    else
                        damage = [(physical_damage * 0.80).round, 0].max
                        damage_type = 'physical'
                    end
                elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                    damage = (magic_damage * 0.80).round
                    damage_type = 'magic'
                elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                    damage = (shadow_damage * 0.80).round
                    damage_type = 'shadow'
                end
                    # Check for the statuses
                    if damage == 0
                        if @opponent_has_missed == true
                            log_message = "#{@opponent.character_name}: #{fervor_image} Fervor - ❌ (MISS)"
                        elsif @character_has_evaded == true
                            log_message = "#{@opponent.character_name}: #{fervor_image} Fervor - 🚫 (EVADE)"
                        else
                            log_message = "#{@opponent.character_name}: #{fervor_image} Fervor -  Damage mitigated"
                        end
                    else
                        if @opponent_has_crit == true && @character_has_ignored_pain == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: #{fervor_image} Fervor - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @opponent_has_crit == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: #{fervor_image} Fervor - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @opponent_has_ignored_pain == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: #{fervor_image} Fervor - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        else
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: #{fervor_image} Fervor - <strong>#{damage}</strong> #{damage_type} damage"
                        end
                    end
                    if @opponent.is_a?(Character)
                        @opponent.apply_combat_skills
                    end
                @combat_logs << log_message
                healing_after_attack(damage)
                buffs_after_attack
                damage_after_attack(damage)
            end
            # Swift movements - Nightstalker talent
            if @opponent.skills.find_by(name: 'Swift Movements', unlocked: true).present?
                # Picks the element of attack
                if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                    if @opponent.is_a?(Character) && (@opponent.feet.present? && @opponent.feet.name == "Voidwalkers")
                        damage = [(physical_damage * 0.50).round, 0].max
                        damage_type = 'shadow'
                    else
                        damage = [(physical_damage * 0.50).round, 0].max
                        damage_type = 'physical'
                    end
                elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                    damage = (magic_damage * 0.5).round
                    damage_type = 'magic'
                elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                    damage = (shadow_damage * 0.5).round
                    damage_type = 'shadow'
                end
                chance_of_additional_attack = @opponent.agility
                if rand(0.0..5000.0) <= chance_of_additional_attack
                    swift_movements_image = "<img src='/assets/nightstalker_skills/swiftmovements.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    # Check for the statuses of an attack
                    if damage == 0
                        if @opponent_has_missed == true
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - ❌ (MISS)"
                        elsif @character_has_evaded == true
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - 🚫 (EVADE)"
                        else
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements -  Damage mitigated"
                        end
                    else
                        if @opponent_has_crit == true && @character_has_ignored_pain == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @opponent_has_crit == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                        elsif @character_has_ignored_pain == true
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                        else
                            @character.total_health -= [damage, 0].max
                            log_message = "#{@opponent.character_name}: #{swift_movements_image} Swift Movements - <strong>#{damage}</strong> #{damage_type} damage"
                        end
                    end
                    if @opponent.is_a?(Character)
                        @opponent.apply_combat_skills
                    end
                @combat_logs << log_message
                healing_after_attack(damage)
                buffs_after_attack
                damage_after_attack(damage)
                end
                # Additional attack items
                # Hellbound
                if (rand(0..100) <= 10) && (@opponent.main_hand.present? && @opponent.main_hand.name == "Hellbound") || (@opponent.off_hand.present? && @opponent.off_hand.name == "Hellbound")
                    hellbound_image = "<img src='/assets/images/legendary_items/hellbound.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                    if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                        if @opponent.is_a?(Character) && (@opponent.feet.present? && @opponent.feet.name == "Voidwalkers")
                            damage = [(physical_damage * 1.5).round, 0].max
                            damage_type = 'shadow'
                        else
                            damage = [(physical_damage * 1.5).round, 0].max
                            damage_type = 'physical'
                        end
                    elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                        damage = (magic_damage * 1.5).round
                        damage_type = 'magic'
                    elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                        damage = (shadow_damage * 1.5).round
                        damage_type = 'shadow'
                    end
                        # Check for the statuses
                        if damage == 0
                            if @opponent_has_missed == true
                                log_message = "#{@opponent.character_name}: #{hellbound_image} Hellbound - ❌ (MISS)"
                            elsif @character_has_evaded == true
                                log_message = "#{@opponent.character_name}: #{hellbound_image} Hellbound - 🚫 (EVADE)"
                            else
                                log_message = "#{@opponent.character_name}: #{hellbound_image} Hellbound -  Damage mitigated"
                            end
                        else
                            if @opponent_has_crit == true && @character_has_ignored_pain == true
                                @character.total_health -= [damage, 0].max
                                log_message = "#{@opponent.character_name}: #{hellbound_image} Hellbound - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                            elsif @opponent_has_crit == true
                                @character.total_health -= [damage, 0].max
                                log_message = "#{@opponent.character_name}: #{hellbound_image} Hellbound - ❗ (CRITICAL STRIKE) <strong>#{damage}</strong> #{damage_type} damage"
                            elsif @character_has_ignored_pain == true
                                @character.total_health -= [damage, 0].max
                                log_message = "#{@opponent.character_name}: #{hellbound_image} Hellbound - 🛡️ (IGNORE PAIN) <strong>#{damage}</strong> #{damage_type} damage"
                            else
                                @character.total_health -= [damage, 0].max
                                log_message = "#{@opponent.character_name}: #{hellbound_image} Hellbound - <strong>#{damage}</strong> #{damage_type} damage"
                            end
                        end
                        if @opponent.is_a?(Character)
                            @opponent.apply_combat_skills
                        end
                    @combat_logs << log_message
                    healing_after_attack(damage)
                    buffs_after_attack
                    damage_after_attack(damage)
                end
            end
        # Character took damage is now true if damage is positive
        @character.took_damage = true if damage.positive?
    end

    def damage_end_of_turn
        # Character turn
        if @character_turn
############# Damage end of turn items
            # The First Flame
            if @character.neck.present? && @character.neck.name == "The First Flame"
            the_first_flame_image = "<img src='/assets/legendary_items/thefirstflame.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                if rand(0.00..100.00) <= 10.0
                    the_first_flame_damage = [(@opponent.total_max_health * 0.08).round, 0].max
                    @opponent_health_in_combat -= the_first_flame_damage
                    log_message = "#{@character.character_name}: #{the_first_flame_image} Flicker of Destruction - <strong>#{the_first_flame_damage}</strong> fire damage"
                    @combat_logs << log_message
                    # Opponent took damage is now true if damage is positive
                    @opponent.took_damage = true if the_first_flame_damage.positive?
                end
            end
            # Laceration
            if (@character.main_hand.present? && @character.main_hand.name == "Laceration") ||
            (@character.off_hand.present? && @character.off_hand.name == "Laceration")
            laceration_image = "<img src='/assets/legendary_items/laceration.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    laceration_damage = [(physical_damage * 0.30).round, 0].max
                    damage_type = 'physical'
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    laceration_damage = [(magic_damage * 0.30).round, 0].max
                    damage_type = 'magic'
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    laceration_damage = [(shadow_damage * 0.30).round, 0].max
                    damage_type = 'shadow'
                end
                # Check for the statuses
                if laceration_damage == 0
                    if @character_has_missed == true
                        log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - ❌ (MISS)"
                    elsif @opponent_has_evaded == true
                        log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - 🚫 (EVADE)"
                    else
                        log_message = "#{@character.character_name}: #{laceration_image} Lethal Strikes - Damage mitigated"
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
                    @combat_logs << log_message
                end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if laceration_damage.positive?
            end
            # Tempest Band
            if (@character.finger1.present? && @character.finger1.name == "Tempest Band") || (@character.finger2.present? && @character.finger2.name == "Tempest Band")
                tempest_band_image = "<img src='/assets/legendary_items/tempestband.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                tempest_band_damage = [(magic_damage * 0.18).round, 0].max
                damage_type = 'magic'
                # Check for the statuses
                if [tempest_band_damage, 0].max == 0
                    if @character_has_missed == true
                        log_message = "#{@character.character_name}: #{tempest_band_image} Stormcaller's Embrace - ❌ (MISS)"
                    elsif @opponent_has_evaded == true
                        log_message = "#{@character.character_name}: #{tempest_band_image} Stormcaller's Embrace - 🚫 (EVADE)"
                    else
                        log_message = "#{@character.character_name}: #{tempest_band_image} Stormcaller's Embrace - Damage mitigated"
                    end
                else
                    if @character_has_crit == true && @opponent_has_ignored_pain == true
                        @opponent_health_in_combat -= [tempest_band_damage, 0].max
                        log_message = "#{@character.character_name}: #{tempest_band_image} Stormcaller's Embrace - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{[tempest_band_damage, 0].max}</strong> #{damage_type} damage"
                    elsif @character_has_crit == true
                        @opponent_health_in_combat -= [tempest_band_damage, 0].max
                        log_message = "#{@character.character_name}: #{tempest_band_image} Stormcaller's Embrace - ❗ (CRITICAL STRIKE) <strong>#{[tempest_band_damage, 0].max}</strong> #{damage_type} damage"
                    elsif @opponent_has_ignored_pain == true
                        @opponent_health_in_combat -= [tempest_band_damage, 0].max
                        log_message = "#{@character.character_name}: #{tempest_band_image} Stormcaller's Embrace - 🛡️ (IGNORE PAIN) <strong>#{[tempest_band_damage, 0].max}</strong> #{damage_type} damage"
                    else
                        @opponent_health_in_combat -= [tempest_band_damage, 0].max
                        log_message = "#{@character.character_name}: #{tempest_band_image} Stormcaller's Embrace - <strong>#{[tempest_band_damage, 0].max}</strong> #{damage_type} damage"
                    end
                end
                @combat_logs << log_message
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if tempest_band_damage.positive?
            end
            # Stormweavers
            if (@character.hands.present? && @character.hands.name == "Stormweavers")
                stormweavers_image = "<img src='/assets/legendary_items/stormweavers.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                stormweavers_damage = [(magic_damage * 0.20).round, 0].max
                damage_type = 'magic'
                # Check for the statuses
                if [stormweavers_damage, 0].max == 0
                    if @character_has_missed == true
                        log_message = "#{@character.character_name}: #{stormweavers_image} Arcane Tempest - ❌ (MISS)"
                    elsif @opponent_has_evaded == true
                        log_message = "#{@character.character_name}: #{stormweavers_image} Arcane Tempest - 🚫 (EVADE)"
                    else
                        log_message = "#{@character.character_name}: #{stormweavers_image} Arcane Tempest - Damage mitigated"
                    end
                else
                    if @character_has_crit == true && @opponent_has_ignored_pain == true
                        @opponent_health_in_combat -= [stormweavers_damage, 0].max
                        log_message = "#{@character.character_name}: #{stormweavers_image} Arcane Tempest - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{[stormweavers_damage, 0].max}</strong> #{damage_type} damage"
                    elsif @character_has_crit == true
                        @opponent_health_in_combat -= [stormweavers_damage, 0].max
                        log_message = "#{@character.character_name}: #{stormweavers_image} Arcane Tempest - ❗ (CRITICAL STRIKE) <strong>#{[stormweavers_damage, 0].max}</strong> #{damage_type} damage"
                    elsif @opponent_has_ignored_pain == true
                        @opponent_health_in_combat -= [stormweavers_damage, 0].max
                        log_message = "#{@character.character_name}: #{stormweavers_image} Arcane Tempest - 🛡️ (IGNORE PAIN) <strong>#{[stormweavers_damage, 0].max}</strong> #{damage_type} damage"
                    else
                        @opponent_health_in_combat -= [stormweavers_damage, 0].max
                        log_message = "#{@character.character_name}: #{stormweavers_image} Arcane Tempest - <strong>#{[stormweavers_damage, 0].max}</strong> #{damage_type} damage"
                    end
                end
                @combat_logs << log_message
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if stormweavers_damage.positive?
            end
            # Necroclasp
            if (@character.hands.present? && @character.hands.name == "Necroclasp")
                necroclasp_image = "<img src='/assets/legendary_items/necroclasp.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                necroclasp_damage = (@character.total_max_health * 0.06).round
                @character.total_health -= [necroclasp_damage, 0].max
                @character.buffed_min_necrosurge += (@character.total_min_necrosurge * 0.03)
                @character.buffed_max_necrosurge += (@character.total_max_necrosurge * 0.03)
                log_message = "#{@character.character_name}: #{necroclasp_image} Vile Embrace - sacrificed <strong>#{necroclasp_damage}</strong> Health. ⬆️ Necrosurge increased by <strong>3%</strong>"
                @combat_logs << log_message
                # Character took damage is now true if damage is positive
                @character.took_damage = true if necroclasp_damage.positive?
            end
            # Nethil
            if (@character.main_hand.present? && @character.main_hand.name == "Nethil") ||
            (@character.off_hand.present? && @character.off_hand.name == "Nethil")
                nethil_image = "<img src='/assets/legendary_items/nethil.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                nethil_damage = 333
                @opponent_health_in_combat -= [nethil_damage, 0].max
                @character.total_health += [nethil_damage, @character.total_max_health - @character.total_health].min
                log_message = "#{@character.character_name}: #{nethil_image} Necrotic Touch - <strong>#{nethil_damage}</strong> shadow damage, <strong>#{damage}</strong> Health recovery"
                @combat_logs << log_message
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if nethil_damage.positive?
            end
############# Damage end of turn talents
            # Crimson Torrent
            if @character.skills.find_by(name: 'Crimson Torrent', unlocked: true).present?
                crimson_torrent_image = "<img src='/assets/deathwalker_skills/crimsontorrent.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                crimson_torrent_damage = (@character.total_max_health * 0.03).round
                @opponent_health_in_combat -= crimson_torrent_damage
                log_message = "#{@character.character_name}: #{crimson_torrent_image} Crimson Torrent - <strong>#{crimson_torrent_damage}</strong> shadow damage"
                @combat_logs << log_message
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if crimson_torrent_damage.positive?
            end
            # Lifetap
            if @character.skills.find_by(name: 'Lifetap', unlocked: true).present?
                lifetap_image = "<img src='/assets/deathwalker_skills/lifetap.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                lifetap_damage = (@character.total_max_health * 0.01).round
                @character.total_health -= [lifetap_damage, 0].max
                @character.buffed_min_necrosurge += lifetap_damage
                @character.buffed_max_necrosurge += lifetap_damage
                log_message = "#{@character.character_name}: #{lifetap_image} Lifetap - sacrificed <strong>#{lifetap_damage}</strong> Health. ⬆️ Necrosurge increased by <strong>#{lifetap_damage}</strong>"
                @combat_logs << log_message
                # Character took damage is now true if damage is positive
                @character.took_damage = true if lifetap_damage.positive?
            end
            # Deep Wounds
            if (@opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Deep Wounds', unlocked: true).present?) && @opponent_deep_wounds_turn > 0
                deep_wounds_image = "<img src='/assets/warrior_skills/deepwounds.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health -= [@opponent_deep_wounds_damage, 0].max
                log_message = "#{@opponent.character_name}: #{deep_wounds_image} Deep Wounds - <strong>#{@opponent_deep_wounds_damage}</strong> physical damage"
                @combat_logs << log_message
                # Character took damage is now true if damage is positive
                @character.took_damage = true if @opponent_deep_wounds_damage.positive?
            end
            # Ephemeral Rebirth
            if @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth == true
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                ephemeral_rebirth_damage = (@character.total_max_health * 0.10).round
                @character.total_health -= [ephemeral_rebirth_damage, 0].max
                log_message = "#{@character.character_name}: #{ephemeral_rebirth_image} Ephemeral Rebirth - lost <strong>#{ephemeral_rebirth_damage}</strong> Health"
                @combat_logs << log_message
                # Character took damage is now true if damage is positive
                @character.took_damage = true if ephemeral_rebirth_damage.positive?
            end
        elsif @opponent_turn && @opponent.is_a?(Character)
############# Damage end of turn items
            # The First Flame
            if @opponent.neck.present? && @opponent.neck.name == "The First Flame"
            thefirstflame_image = "<img src='/assets/legendary_items/thefirstflame.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                if rand(0.00..100.00) <= 10.0
                    damage = [(@character.total_max_health * 0.08).round, 0].max
                    @character.total_health -= damage
                    log_message = "#{@opponent.character_name}: #{thefirstflame_image} Flicker of Destruction - <strong>#{damage}</strong> fire damage"
                    @combat_logs << log_message
                    # Character took damage is now true if damage is positive
                    @character.took_damage = true if the_first_flame_damage.positive?
                end
            end
            # Laceration
            if (@opponent.main_hand.present? && @opponent.main_hand.name == "Laceration") ||
            (@opponent.off_hand.present? && @opponent.off_hand.name == "Laceration")
            laceration_image = "<img src='/assets/legendary_items/laceration.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                laceration_damage = [(physical_damage * 0.30).round, 0].max
                damage_type = 'physical'
            elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                laceration_damage = [(magic_damage * 0.30).round, 0].max
                damage_type = 'magic'
            elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                laceration_damage = [(shadow_damage * 0.30).round, 0].max
                damage_type = 'shadow'
            end
            # Check for the statuses
            if laceration_damage == 0
                if @opponent_has_missed == true
                    log_message = "#{@opponent.character_name}: #{laceration_image} Lethal Strikes - ❌ (MISS)"
                elsif @character_has_evaded == true
                    log_message = "#{@opponent.character_name}: #{laceration_image} Lethal Strikes - 🚫 (EVADE)"
                else
                    log_message = "#{@opponent.character_name}: #{laceration_image} Lethal Strikes - Damage mitigated"
                end
            else
                if @opponent_has_crit == true && @character_has_ignored_pain == true
                    @character.total_health -= [laceration_damage, 0].max
                    log_message = "#{@opponent.character_name}: #{laceration_image} Lethal Strikes - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{laceration_damage}</strong> #{damage_type} damage"
                elsif @opponent_has_crit == true
                    @character.total_health -= [laceration_damage, 0].max
                    log_message = "#{@opponent.character_name}: #{laceration_image} Lethal Strikes - ❗ (CRITICAL STRIKE) <strong>#{laceration_damage}</strong> #{damage_type} damage"
                elsif @character_has_ignored_pain == true
                    @character.total_health -= [laceration_damage, 0].max
                    log_message = "#{@opponent.character_name}: #{laceration_image} Lethal Strikes - 🛡️ (IGNORE PAIN) <strong>#{laceration_damage}</strong> #{damage_type} damage"
                else
                    @character.total_health -= [laceration_damage, 0].max
                    log_message = "#{@opponent.character_name}: #{laceration_image} Lethal Strikes - <strong>#{laceration_damage}</strong> #{damage_type} damage"
                end
                @combat_logs << log_message
            end
            # Character took damage is now true if damage is positive
            @character.took_damage = true if laceration_damage.positive?
            end
            # Tempest Band
            if (@opponent.finger1.present? && @opponent.finger1.name == "Tempest Band") || (@opponent.finger2.present? && @opponent.finger2.name == "Tempest Band")
                tempest_band_image = "<img src='/assets/legendary_items/tempestband.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                tempest_band_damage = [(magic_damage * 0.18).round, 0].max
                damage_type = 'magic'
                # Check for the statuses
                if [tempest_band_damage, 0].max == 0
                    if @opponent_has_missed == true
                        log_message = "#{@opponent.character_name}: #{tempest_band_image} Stormcaller's Embrace - ❌ (MISS)"
                    elsif @character_has_evaded == true
                        log_message = "#{@opponent.character_name}: #{tempest_band_image} Stormcaller's Embrace - 🚫 (EVADE)"
                    else
                        log_message = "#{@opponent.character_name}: #{tempest_band_image} Stormcaller's Embrace - Damage mitigated"
                    end
                else
                    if @opponent_has_crit == true && @character_has_ignored_pain == true
                        @character.total_health -= [tempest_band_damage, 0].max
                        log_message = "#{@opponent.character_name}: #{tempest_band_image} Stormcaller's Embrace - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{[tempest_band_damage, 0].max}</strong> #{damage_type} damage"
                    elsif @opponent_has_crit == true
                        @character.total_health -= [tempest_band_damage, 0].max
                        log_message = "#{@opponent.character_name}: #{tempest_band_image} Stormcaller's Embrace - ❗ (CRITICAL STRIKE) <strong>#{[tempest_band_damage, 0].max}</strong> #{damage_type} damage"
                    elsif @character_has_ignored_pain == true
                        @character.total_health -= [tempest_band_damage, 0].max
                        log_message = "#{@opponent.character_name}: #{tempest_band_image} Stormcaller's Embrace - 🛡️ (IGNORE PAIN) <strong>#{[tempest_band_damage, 0].max}</strong> #{damage_type} damage"
                    else
                        @character.total_health -= [tempest_band_damage, 0].max
                        log_message = "#{@opponent.character_name}: #{tempest_band_image} Stormcaller's Embrace - <strong>#{[tempest_band_damage, 0].max}</strong> #{damage_type} damage"
                    end
                end
                @combat_logs << log_message
                # Character took damage is now true if damage is positive
                @character.took_damage = true if tempest_band_damage.positive?
            end
            # Stormweavers
            if (@opponent.hands.present? && @opponent.hands.name == "Stormweavers")
                stormweavers_image = "<img src='/assets/legendary_items/stormweavers.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                stormweavers_damage = [(magic_damage * 0.20).round, 0].max
                damage_type = 'magic'
                # Check for the statuses
                if [stormweavers_damage, 0].max == 0
                    if @opponent_has_missed == true
                        log_message = "#{@opponent.character_name}: #{stormweavers_image} Arcane Tempest - ❌ (MISS)"
                    elsif @character_has_evaded == true
                        log_message = "#{@opponent.character_name}: #{stormweavers_image} Arcane Tempest - 🚫 (EVADE)"
                    else
                        log_message = "#{@opponent.character_name}: #{stormweavers_image} Arcane Tempest - Damage mitigated"
                    end
                else
                    if @opponent_has_crit == true && @character_has_ignored_pain == true
                        @character.total_health -= [stormweavers_damage, 0].max
                        log_message = "#{@opponent.character_name}: #{stormweavers_image} Arcane Tempest - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{[stormweavers_damage, 0].max}</strong> #{damage_type} damage"
                    elsif @opponent_has_crit == true
                        @character.total_health -= [stormweavers_damage, 0].max
                        log_message = "#{@opponent.character_name}: #{stormweavers_image} Arcane Tempest - ❗ (CRITICAL STRIKE) <strong>#{[stormweavers_damage, 0].max}</strong> #{damage_type} damage"
                    elsif @character_has_ignored_pain == true
                        @character.total_health -= [stormweavers_damage, 0].max
                        log_message = "#{@opponent.character_name}: #{stormweavers_image} Arcane Tempest - 🛡️ (IGNORE PAIN) <strong>#{[stormweavers_damage, 0].max}</strong> #{damage_type} damage"
                    else
                        @character.total_health -= [stormweavers_damage, 0].max
                        log_message = "#{@opponent.character_name}: #{stormweavers_image} Arcane Tempest - <strong>#{[stormweavers_damage, 0].max}</strong> #{damage_type} damage"
                    end
                end
                @combat_logs << log_message
                # Character took damage is now true if damage is positive
                @character.took_damage = true if stormweavers_damage.positive?
            end
            # Necroclasp
            if (@opponent.hands.present? && @opponent.hands.name == "Necroclasp")
                necroclasp_image = "<img src='/assets/legendary_items/necroclasp.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                necroclasp_damage = (@opponent.total_max_health * 0.06).round
                @opponent_health_in_combat -= [necroclasp_damage, 0].max
                @opponent.buffed_min_necrosurge += (@opponent.total_min_necrosurge * 0.03)
                @opponent.buffed_max_necrosurge += (@opponent.total_max_necrosurge * 0.03)
                log_message = "#{@opponent.character_name}: #{necroclasp_image} Vile Embrace - sacrificed <strong>#{necroclasp_damage}</strong> Health. ⬆️ Necrosurge increased by <strong>3%</strong>"
                @combat_logs << log_message
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if necroclasp_damage.positive?
            end
            # Nethil
            if (@opponent.main_hand.present? && @opponent.main_hand.name == "Nethil") ||
            (@opponent.off_hand.present? && @opponent.off_hand.name == "Nethil")
                nethil_image = "<img src='/assets/legendary_items/nethil.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                nethil_damage = 333
                @character.total_health -= [nethil_damage, 0].max
                @opponent_health_in_combat += [nethil_damage, @opponent.total_max_health - @opponent_health_in_combat].min
                log_message = "#{@opponent.character_name}: #{nethil_image} Necrotic Touch - <strong>#{nethil_damage}</strong> shadow damage, <strong>#{nethil_damage}</strong> Health recovery"
                @combat_logs << log_message
                # Character took damage is now true if damage is positive
                @character.took_damage = true if nethil_damage.positive?
            end
############# Damage end of turn talents
            # Crimson Torrent
            if @opponent.skills.find_by(name: 'Crimson Torrent', unlocked: true).present?
                crimson_torrent_image = "<img src='/assets/deathwalker_skills/crimsontorrent.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                crimson_torrent_damage = (@opponent.total_max_health * 0.03).round
                @character.total_health -= crimson_torrent_damage
                log_message = "#{@opponent.character_name}: #{crimson_torrent_image} Crimson Torrent - <strong>#{crimson_torrent_damage}</strong> shadow damage"
                @combat_logs << log_message
                # Character took damage is now true if damage is positive
                @character.took_damage = true if crimson_torrent_damage.positive?
            end

            # Lifetap
            if @opponent.skills.find_by(name: 'Lifetap', unlocked: true).present?
                lifetap_image = "<img src='/assets/deathwalker_skills/lifetap.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                lifetap_damage = (@opponent.total_max_health * 0.01).round
                @opponent_health_in_combat -= [lifetap_damage, 0].max
                @opponent.buffed_min_necrosurge += lifetap_damage
                @opponent.buffed_max_necrosurge += lifetap_damage
                log_message = "#{@opponent.character_name}: #{lifetap_image} Lifetap - sacrificed <strong>#{lifetap_damage}</strong> Health. ⬆️ Necrosurge increased by <strong>#{lifetap_damage}</strong>"
                @combat_logs << log_message
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if lifetap_damage.positive?
            end

            # Deep Wounds
            if @character.skills.find_by(name: 'Deep Wounds', unlocked: true).present? && @character_deep_wounds_turn > 0
                deep_wounds_image = "<img src='/assets/warrior_skills/deepwounds.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat -= [@character_deep_wounds_damage, 0].max
                log_message = "#{@character.character_name}: #{deep_wounds_image} Deep Wounds - <strong>#{@character_deep_wounds_damage}</strong> physical damage"
                @combat_logs << log_message
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if @character_deep_wounds_damage.positive?
            end

            # Ephemeral Rebirth
            if @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth == true
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                ephemeral_rebirth_damage = (@opponent.total_max_health * 0.10).round
                @opponent_health_in_combat -= [ephemeral_rebirth_damage, 0].max
                log_message = "#{@opponent.character_name}: #{ephemeral_rebirth_image} Ephemeral Rebirth - lost <strong>#{ephemeral_rebirth_damage}</strong> Health"
                @combat_logs << log_message
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if ephemeral_rebirth_damage.positive?
            end
        end
    end

    def execution_effects
        if @character_turn
            # Dawnbreaker
            if ((@opponent_health_in_combat <= (@opponent.total_max_health * 0.10)) && ((@character.main_hand.present? && @character.main_hand.name == "Dawnbreaker") ||
            (@character.off_hand.present? && @character.off_hand.name == "Dawnbreaker")))
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
                            else
                                log_message = "#{@character.character_name}: #{dawnbreaker_image} Dawn's Judgement - Damage mitigated"
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
                    # Opponent took damage is now true if damage is positive
                    @opponent.took_damage = true if dawnbreaker_damage.positive?
            end
        elsif @opponent_turn && @opponent.is_a?(Character)
            # Dawnbreaker
            if ((@character.total_health <= (@character.total_max_health * 0.10)) && ((@opponent.main_hand.present? && @opponent.main_hand.name == "Dawnbreaker") ||
            (@opponent.off_hand.present? && @opponent.off_hand.name == "Dawnbreaker")))
                dawnbreaker_image = "<img src='/assets/legendary_items/dawnbreaker.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawn's Judgement' class='log-skill-image'>"
                    if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                        dawnbreaker_damage = (physical_damage * 1.11).round
                        damage_type = 'physical'
                    elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                        dawnbreaker_damage = (magic_damage * 1.11).round
                        damage_type = 'magic'
                    elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                        dawnbreaker_damage = (shadow_damage * 1.11).round
                        damage_type = 'shadow'
                    end
                        # Check for the statuses
                        if dawnbreaker_damage == 0
                            if @opponent_has_missed == true
                                log_message = "#{@opponent.character_name}: #{dawnbreaker_image} Dawn's Judgement - ❌ (MISS)"
                            elsif @character_has_evaded == true
                                log_message = "#{@opponent.character_name}: #{dawnbreaker_image} Dawn's Judgement - 🚫 (EVADE)"
                            else
                                log_message = "#{@opponent.character_name}: #{dawnbreaker_image} Dawn's Judgement - Damage mitigated"
                            end
                        else
                            if @opponent_has_crit == true && @character_has_ignored_pain == true
                                @character.total_health -= [dawnbreaker_damage, 0].max
                                log_message = "#{@opponent.character_name}: #{dawnbreaker_image} Dawn's Judgement - ❗ (CRITICAL STRIKE), 🛡️ (IGNORE PAIN) <strong>#{dawnbreaker_damage}</strong> #{damage_type} damage"
                            elsif @opponent_has_crit == true
                                @character.total_health -= [dawnbreaker_damage, 0].max
                                log_message = "#{@opponent.character_name}: #{dawnbreaker_image} Dawn's Judgement - ❗ (CRITICAL STRIKE) <strong>#{dawnbreaker_damage}</strong> #{damage_type} damage"
                            elsif @character_has_ignored_pain == true
                                @character.total_health -= [dawnbreaker_damage, 0].max
                                log_message = "#{@opponent.character_name}: #{dawnbreaker_image} Dawn's Judgement - 🛡️ (IGNORE PAIN) <strong>#{dawnbreaker_damage}</strong> #{damage_type} damage"
                            else
                                @character.total_health -= [dawnbreaker_damage, 0].max
                                log_message = "#{@opponent.character_name}: #{dawnbreaker_image} Dawn's Judgement - <strong>#{dawnbreaker_damage}</strong> #{damage_type} damage"
                            end
                        end
                    @combat_logs << log_message
                    # Character took damage is now true if damage is positive
                    @character.took_damage = true if dawnbreaker_damage.positive?
                    end
            end
        end
    end

    def cheat_deaths
        if @character_turn
            # Death's Bargain
            if (@opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.off_hand.present? && @opponent.off_hand.name  == "Death's Bargain") && @opponent.deathsbargain  == false
                deathsbargain_image = "<img src='/assets/legendary_items/deathsbargain.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat = 1
                @opponent.deathsbargain = true
                log_message = "#{@opponent.character_name}: #{deathsbargain_image} Death's Bargain triggered " if @opponent.deathsbargain == true
                @combat_logs << log_message
            end
            # Nullify
            if @opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Nullify', unlocked: true).present? && @opponent.nullify == false
                nullify_image = "<img src='/assets/mage_skills/nullify.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat = 1
                @opponent.nullify = true
                log_message = "#{@opponent.character_name}: #{nullify_image} Nullify triggered" if @opponent.nullify == true
                @combat_logs << log_message
            end
            # Ephemeral Rebirth - Initialize
            if @opponent.is_a?(Character) && @opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth  == false
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat = @opponent.total_max_health
                @opponent.ephemeral_rebirth = true
                log_message = "#{@opponent.character_name}: #{ephemeral_rebirth_image} Ephemeral Rebirth triggered" if @opponent.ephemeral_rebirth == true
                @combat_logs << log_message
            end

        elsif @opponent_turn
            # Death's Bargain
            if @character.total_health <= 0 && (@character.off_hand.present? && @character.off_hand.name  == "Death's Bargain") && @character.deathsbargain  == false
                deathsbargain_image = "<img src='/assets/legendary_items/deathsbargain.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health = 1
                @character.deathsbargain = true
                log_message = "#{@character.character_name}: #{deathsbargain_image} Death's Bargain triggered " if @character.deathsbargain == true
                @combat_logs << log_message
            end
            # Nullify
            if @opponent.is_a?(Character) && @character.total_health <= 0 && @character.skills.find_by(name: 'Nullify', unlocked: true).present? && @character.nullify == false
                nullify_image = "<img src='/assets/mage_skills/nullify.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health = 1
                @character.nullify = true
                log_message = "#{@character.character_name}: #{nullify_image} Nullify triggered" if @character.nullify == true
                @combat_logs << log_message
            end
            # Ephemeral Rebirth - Initialize
            if @opponent.is_a?(Character) && @character.total_health <= 0 && @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth  == false
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health = @character.total_max_health
                @character.ephemeral_rebirth = true
                log_message = "#{@opponent.character_name}: #{ephemeral_rebirth_image} Ephemeral Rebirth triggered" if @character.ephemeral_rebirth == true
                @combat_logs << log_message
            end
        end
    end

    def log_health_values
        if (@opponent.is_a?(Character) && @opponent.took_damage == true)
            if @opponent_health_in_combat <= 0
                log_message = "#{@opponent.character_name}: ☠ <span style=\"text-decoration: underline;\"><strong>#{@opponent_health_in_combat} / #{@opponent.total_max_health}</strong></span> Health"
                @combat_logs << log_message
            else
                log_message = "#{@opponent.character_name}: <span style=\"text-decoration: underline;\"><strong>#{@opponent_health_in_combat} / #{@opponent.total_max_health}</strong></span> Health"
                @combat_logs << log_message
            end
        elsif (@opponent.is_a?(Monster) && @opponent.took_damage == true)
            if @opponent_health_in_combat <= 0
                log_message = "#{@opponent.monster_name}: ☠ <span style=\"text-decoration: underline;\"><strong>#{@opponent_health_in_combat} / #{@opponent.total_max_health}</strong></span> Health"
                @combat_logs << log_message
            else
                log_message = "#{@opponent.monster_name}: <span style=\"text-decoration: underline;\"><strong>#{@opponent_health_in_combat} / #{@opponent.total_max_health}</strong></span> Health"
                @combat_logs << log_message
            end
        end
        if @character.took_damage == true
            if @character.total_health <= 0
                log_message = "#{@character.character_name}: ☠ <span style=\"text-decoration: underline;\"><strong>#{@character.total_health} / #{@character.total_max_health}</strong></span> Health"
                @combat_logs << log_message
            else
                log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\"><strong>#{@character.total_health} / #{@character.total_max_health}</strong></span> Health"
                @combat_logs << log_message
            end
        end
    end

    def character_turn
        # Blessing of kings - Paladin talent
        @character_blessing_of_kings_turn -= 1 unless @character_blessing_of_kings_turn == 0
        if @character.skills.find_by(name: 'Blessing of Kings', unlocked: true).present? && (@character_blessing_of_kings_turn == 0 && @character.blessing_of_kings == false)
            @character.blessing_of_kings = true
            @character_blessing_of_kings_turn = 4

            blessing_of_kings_image = "<img src='/assets/paladin_skills/blessingofkings.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            log_message = "#{@character.character_name}: #{blessing_of_kings_image} Blessing of Kings triggered"
            @combat_logs << log_message
        end
        # Piety - Paladin talent
        if @character.skills.find_by(name: 'Piety', unlocked: true).present? && (@character.total_health <= (@character.total_max_health * 0.5 )) && @character.piety == false
            piety = (@character.total_max_health * 0.20).round
            piety_image = "<img src='/assets/paladin_skills/piety.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            @character.total_health += [piety, @character.total_max_health - @character.total_health].min
            @character.piety = true
            log_message = "#{@character.character_name}: #{piety_image} Piety - <strong>#{piety}</strong> Health recovery"
            @combat_logs << log_message
        end
        # After damage taken talents
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

        basic_attacks
        additional_attacks
        damage_end_of_turn
        execution_effects
        cheat_deaths
        log_health_values

        # Reset took damage to false
        @character.took_damage = false
    end

    def opponent_turn
        # Blessing of kings - Paladin talent
        @opponent_blessing_of_kings_turn -= 1 unless @opponent_blessing_of_kings_turn == 0
        if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Blessing of Kings', unlocked: true).present? && (@opponent_blessing_of_kings_turn == 0 && @opponent.blessing_of_kings == false)
            @opponent.blessing_of_kings = true
            @opponent_blessing_of_kings_turn = 4

            blessing_of_kings_image = "<img src='/assets/paladin_skills/blessingofkings.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            log_message = "#{@opponent.character_name}: #{blessing_of_kings_image} Blessing of Kings triggered"
            @combat_logs << log_message
        end
        if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Piety', unlocked: true).present? && (@opponent_health_in_combat <= (@opponent.total_max_health* 0.50 )) && @opponent.piety == false
            piety_image = "<img src='/assets/paladin_skills/piety.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            piety = (@opponent.total_max_health * 0.20).round
            @opponent_health_in_combat += [piety, @opponent.total_max_health - @opponent_health_in_combat].min
            @opponent.piety = true
            log_message = "#{@opponent.character_name}: #{piety_image} Piety - <strong>#{piety}</strong> Health recovery"
            @combat_logs << log_message
        end
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

        basic_attacks
        additional_attacks
        damage_end_of_turn
        execution_effects
        cheat_deaths
        log_health_values

        @opponent.took_damage = false
    end

end
