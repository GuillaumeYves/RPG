class CombatController < ApplicationController

    def determine_opponent
        opponent_id = params[:opponent_id]
        character_id = current_user.selected_character.id

        if Character.exists?(opponent_id) && opponent_id.to_i != character_id
            Character.find(opponent_id)
        elsif Monster.exists?(opponent_id)
            Monster.find(opponent_id)
        end
    end

    def combat_result
        @opponent = determine_opponent
        @character = current_user.selected_character
        @combat_logs = params[:combat_logs] || []
    end

    def switch_turns
        @character_turn = !@character_turn
        @opponent_turn = !@opponent_turn
    end

    def combat
        puts "################## Combat has started #####################"
        @character = current_user.selected_character
        @opponent = determine_opponent
        @hunt = @selected_character.accepted_hunt

        # Randomly determine the first turn
        @character_turn = rand(2).zero?
        @opponent_turn = !@character_turn

        # Initialize combat
        @combat_result = nil
        @combat_logs = []
        @turn_count = 1

        @character.took_damage = false
        @opponent.took_damage = false

        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats if @opponent.is_a?(Character)

        # Combat loop
        log_message =  "Turn #{@turn_count}"
        @combat_logs << log_message

        while @character.health.positive? && @opponent.health.positive?

            # Character's turn
            if @character_turn
            puts "########### Character - total_attack: #{@character.total_attack}, buffed_attack: #{@character.buffed_attack}, total_armor: #{@character.total_armor}, buffed_armor: #{@character.buffed_armor}, total_critical_strike_chance: #{@character.total_critical_strike_chance}, buffed_critical_strike_chance: #{@character.buffed_critical_strike_chance}, total_critical_strike_damage: #{@character.total_critical_strike_damage}, buffed_critical_strike_damage: #{@character.buffed_critical_strike_damage}"
            character_turn    

            # Opponent's turn
            elsif @opponent_turn
            puts "########### Opponent - total_attack: #{@opponent.total_attack}, buffed_attack: #{@opponent.buffed_attack}, total_armor: #{@opponent.total_armor}, buffed_armor: #{@opponent.buffed_armor}, total_critical_strike_chance: #{@opponent.total_critical_strike_chance}, buffed_critical_strike_chance: #{@opponent.buffed_critical_strike_chance}, total_critical_strike_damage: #{@opponent.total_critical_strike_damage}, buffed_critical_strike_damage: #{@opponent.buffed_critical_strike_damage}"
            opponent_turn
            end

            switch_turns
            @turn_count += 1
            log_message =  "Turn #{@turn_count}"
            @combat_logs << log_message

            # Check if character or opponent is defeated
            break unless @character.health.positive? && @opponent.health.positive?
        end

        # Set combat result based on the outcome
        @combat_result = if @character.health.positive?
                        'Victory'
                        elsif @opponent.health.positive?
                        'Defeat'
                        end
        log_message =  "Combat has ended : #{@combat_result} "
        @combat_logs << log_message

        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats if @opponent.is_a?(Character)

        redirect_to combat_result_path(character_id: @character.id, opponent_id: @opponent.id, combat_logs: @combat_logs)
    end

    def physical_damage(total_attack, buffed_attack, total_armor, buffed_armor, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, evasion, ignore_pain_chance)
        # Check for a critical hit based on critical_strike_chance
        if rand(0.0..100) <= (total_critical_strike_chance + buffed_critical_strike_chance)
                damage = ((total_attack + buffed_attack) * (total_critical_strike_damage + buffed_critical_strike_damage >= 1.0 ? total_critical_strike_damage + buffed_critical_strike_damage: 1.0)) - (total_armor + buffed_armor)
            log_message = "CRITICAL STRIKE"
            @combat_logs << log_message
        else
            damage = (total_attack + buffed_attack) - (total_armor + buffed_armor)
            
            # Apply damage reduction based on ignore_pain_chance
            if rand(0.0..100) <= ignore_pain_chance
                damage *= 0.8  # Reduce incoming damage by 20%
            log_message = "IGNORE PAIN"
            @combat_logs << log_message
            end

            # Chance to evade damage
            if rand(0.0..100) <= evasion
                damage = 0 
            log_message = "EVADED"
            @combat_logs << log_message
            end
        end

        damage
    end

    def magic_damage(total_spellpower, buffed_spellpower, total_magic_resistance, buffed_magic_resistance, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, evasion, ignore_pain_chance)
        # Check for a critical hit based on critical strike chance
        if rand(0.0..100) <= (total_critical_strike_chance + buffed_critical_strike_chance)
            damage = ((total_spellpower + buffed_spellpower) * (total_critical_strike_damage + buffed_critical_strike_damage >= 1.0 ? total_critical_strike_damage + buffed_critical_strike_damage : 1.0)) - (total_magic_resistance + buffed_magic_resistance)
            log_message = "CRITICAL STRIKE"
            @combat_logs << log_message
        else
            damage = (total_spellpower + buffed_spellpower) - (total_magic_resistance + buffed_magic_resistance)

            # Apply damage reduction based on ignore_pain_chance
            if rand(0.0..100) <= ignore_pain_chance
                damage *= 0.8  # Reduce incoming damage by 20%
            log_message = "IGNORE PAIN"
            @combat_logs << log_message
            end

            # Chance to evade damage
            if rand(0.0..100) <= evasion
                damage = 0 
            log_message = "EVADED"
            @combat_logs << log_message
            end
        end

        damage
    end

    def calculate_damage(character, opponent)
        if @character_turn
            if @character.total_attack > @character.total_spellpower
                physical_damage(character.total_attack, character.buffed_attack, opponent.total_armor, opponent.buffed_armor, character.total_critical_strike_chance, character.buffed_critical_strike_chance, character.total_critical_strike_damage, character.buffed_critical_strike_damage, opponent.evasion, opponent.ignore_pain_chance)
            else
                magic_damage(character.total_spellpower, character.buffed_spellpower, opponent.total_magic_resistance, opponent.buffed_magic_resistance, character.total_critical_strike_chance, character.buffed_critical_strike_chance, character.total_critical_strike_damage, character.buffed_critical_strike_damage, opponent.evasion, opponent.ignore_pain_chance)
            end
        elsif @opponent_turn
              if @opponent.total_attack > @opponent.total_spellpower
                physical_damage(opponent.total_attack, opponent.buffed_attack, character.total_armor, character.buffed_armor, opponent.total_critical_strike_chance, opponent.buffed_critical_strike_chance, opponent.total_critical_strike_damage, opponent.buffed_critical_strike_damage, character.evasion, character.ignore_pain_chance)
            else
                magic_damage(opponent.total_spellpower, opponent.buffed_spellpower, character.total_magic_resistance, character.buffed_magic_resistance, opponent.total_critical_strike_chance, opponent.buffed_critical_strike_chance, opponent.total_critical_strike_damage, opponent.buffed_critical_strike_damage, character.evasion, character.ignore_pain_chance)
            end
        end
    end

    def character_turn
        @character.apply_trigger_skills if @character.took_damage == true
        deal_damage(@character, @opponent)
        @character.apply_combat_skills
        @character.took_damage = false 
    end

    def opponent_turn
        @opponent.apply_trigger_skills if @opponent.took_damage == true && @opponent.is_a?(Character)
        deal_damage(@opponent, @character)
        @opponent.apply_combat_skills if @opponent.is_a?(Character)
        @opponent.took_damage = false
    end

    def deal_damage(character, opponent)
        damage = calculate_damage(@character, @opponent)

        if @character_turn
            @opponent.health -= damage
            @opponent.health = [@opponent.health, 0].max
            @opponent.took_damage = true if damage.positive?
            log_message = "#{@character.character_name} attacks for #{damage} damage. #{@opponent.character_name} now has #{@opponent.health} / #{@opponent.max_health} Health."
            @combat_logs << log_message
           
        elsif @opponent_turn
            @character.health -= damage
            @character.health = [@character.health, 0].max
            @character.took_damage = true if damage.positive? 
            log_message = "#{@opponent.character_name} attacks for #{damage} damage. #{@character.character_name} now has #{@character.health} / #{@character.max_health} Health."
            @combat_logs << log_message
        end
    end

end

