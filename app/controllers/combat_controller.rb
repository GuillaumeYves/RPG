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

        @character.took_damage = false
        @opponent.took_damage = false

        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats if @opponent.is_a?(Character)

        # Combat loop
        while @character.health.positive? && @opponent.health.positive?
            # Character's turn
            if @character_turn
            puts "########### Character - total_attack: #{@character.total_attack}, buffed_attack: #{@character.buffed_attack}, total_armor: #{@character.total_armor}, buffed_armor: #{@character.buffed_armor}, total_critical_strike_damage: #{@character.total_critical_strike_damage}"    
            character_turn    
            @character.apply_combat_skills

            # Opponent's turn
            elsif @opponent_turn
            puts "########### Opponent - total_attack: #{@opponent.total_attack}, buffed_attack: #{@opponent.buffed_attack}, total_armor: #{@opponent.total_armor}, buffed_armor: #{@opponent.buffed_armor}, total_critical_strike_damage: #{@opponent.total_critical_strike_damage}"
            opponent_turn
            @opponent.apply_combat_skills if @opponent.is_a?(Character)
            end

            switch_turns

            # Check if character or opponent is defeated
            break unless @character.health.positive? && @opponent.health.positive?
        end

        # Set combat result based on the outcome
        @combat_result = if @character.health.positive?
                        'victory'
                        elsif @opponent.health.positive?
                        'defeat'
                        end
        puts "################## Combat has ended : #{@combat_result} #####################"

        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats if @opponent.is_a?(Character)

        redirect_to combat_result_path(character_id: @character.id, opponent_id: @opponent.id, combat_logs: @combat_logs)
    end

    def physical_damage(total_attack, buffed_attack, total_armor, buffed_armor, total_critical_strike_chance, total_critical_strike_damage, evasion, ignore_pain_chance)
        # Check for a critical hit based on critical_strike_chance
        if rand(0.0..100) <= total_critical_strike_chance
            damage = ((total_attack + buffed_attack) * (total_critical_strike_damage >= 1.0 ? total_critical_strike_damage : 1.0)) - (total_armor + buffed_armor)
            puts "######### CRITICAL STRIKE ###########"
            puts "########### Calculated damage for crit : #{damage}"
        else
            damage = (total_attack + buffed_attack) - (total_armor + buffed_armor)
            
            # Apply damage reduction based on ignore_pain_chance
            if rand(0.0..100) <= ignore_pain_chance
            damage *= 0.8  # Reduce incoming damage by 20%
            puts "######### IGNORE PAIN ###########"
            end

            # Chance to evade damage
            if rand(0.0..100) <= evasion
            damage = 0 
            puts "######### EVADED ###########"
            end
        end

        damage
    end

    def magic_damage(total_spellpower, buffed_spellpower, total_magic_resistance, buffed_magic_resistance, total_critical_strike_chance, total_critical_strike_damage, evasion, ignore_pain_chance)
        # Check for a critical hit based on critical_strike_chance
        if rand(0.0..100) <= total_critical_strike_chance
            damage = ((total_spellpower + buffed_spellpower) * (total_critical_strike_damage >= 1.0 ? total_critical_strike_damage : 1.0)) - (total_magic_resistance + buffed_magic_resistance)
            puts "######### CRITICAL STRIKE ###########"
            puts "########### Calculated damage for crit : #{damage}"
        else
            damage = (total_spellpower + buffed_spellpower) - (total_magic_resistance + buffed_magic_resistance)

            # Apply damage reduction based on ignore_pain_chance
            if rand(0.0..100) <= ignore_pain_chance
                damage *= 0.8  # Reduce incoming damage by 20%
                puts "######### IGNORE PAIN ###########"
            end

            # Chance to evade damage
            if rand(0.0..100) <= evasion
                damage = 0 
                puts "######### EVADED ###########"
            end
        end

        damage
    end

    def calculate_damage(character, opponent)
        if @character_turn
            if @character.total_attack > @character.total_spellpower
                physical_damage(character.total_attack, character.buffed_attack, opponent.total_armor, opponent.buffed_armor, character.total_critical_strike_chance, character.total_critical_strike_damage, opponent.evasion, opponent.ignore_pain_chance)
            else
                magic_damage(character.total_spellpower, character.buffed_spellpower, opponent.total_magic_resistance, opponent.buffed_magic_resistance, character.total_critical_strike_chance, character.total_critical_strike_damage, opponent.evasion, opponent.ignore_pain_chance)
            end
        elsif @opponent_turn
              if @opponent.total_attack > @opponent.total_spellpower
                physical_damage(opponent.total_attack, opponent.buffed_attack, character.total_armor, character.buffed_armor, opponent.total_critical_strike_chance, opponent.total_critical_strike_damage, character.evasion, character.ignore_pain_chance)
            else
                magic_damage(opponent.total_spellpower, opponent.buffed_spellpower, character.total_magic_resistance, character.buffed_magic_resistance, opponent.total_critical_strike_chance, opponent.total_critical_strike_damage, character.evasion, character.ignore_pain_chance)
            end
        end
    end

    def character_turn
        puts "########### Character's turn ############"
        deal_damage(@character, @opponent)
        @character.apply_trigger_skills if @character.took_damage
        @character.took_damage = false 
        puts "################ Opponent now has : #{@opponent.health} / #{@opponent.max_health} ###################"
    end

    def opponent_turn
        puts "########### Opponent's turn ############"
        deal_damage(@opponent, @character)
        @opponent.apply_trigger_skills if @opponent.took_damage
        @opponent.took_damage = false
        puts "################ Character now has : #{@character.health} / #{@character.max_health} ###################"
    end

    def deal_damage(character, opponent)
        damage = calculate_damage(@character, @opponent)

        if @character_turn
            @opponent.health -= damage
            @opponent.health = [@opponent.health, 0].max
            @opponent.took_damage = true if damage.positive?
            puts "################ #{damage} ######################"
           
        elsif @opponent_turn
            @character.health -= damage
            @character.health = [@character.health, 0].max
            @character.took_damage = true if damage.positive? 
            puts "################ #{damage} ######################"
        end
    end

end

