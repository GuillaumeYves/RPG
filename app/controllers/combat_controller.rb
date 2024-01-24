class CombatController < ApplicationController

    def combat
        @character = current_user.selected_character
        @opponent = determine_opponent
        @hunt = @selected_character.accepted_hunt
        
        # Initialize combat
        @combat_result = nil
        @character_turn = false
        @opponent_turn = false
        @character.took_damage = false
        @opponent.took_damage = false

        @character.set_default_values_for_buffed_stats
        if @opponent.is_a?(Character)
            @opponent.set_default_values_for_buffed_stats
        end
        # Combat loop
        while @character.health.positive? && @opponent.health.positive?

            # Character attacks opponent
            @character_turn = true
                character_turn
                @character.apply_combat_skills
            @character_turn = false
            # Check if opponent is defeated
                break unless @opponent.health.positive?
            
            # Opponent attacks character
            @opponent_turn = true
                opponent_turn
                if @opponent.is_a?(Character)
                    @opponent.apply_combat_skills
                end
            @opponent_turn = false
            # Check if character is defeated
                break unless @character.health.positive?
        end

        # Set combat result variables based on the outcome
        @combat_result = @character.health.positive? ? 'victory' : 'defeat'

        @character.set_default_values_for_buffed_stats
        if @opponent.is_a?(Character)
            @opponent.set_default_values_for_buffed_stats
        end

        unless performed?
            render 'combat_result'
        end
    end

    def determine_opponent
        opponent_id = params[:id]
        current_character_id = current_user.selected_character.id

        if Character.exists?(opponent_id) && opponent_id.to_i != current_character_id
            Character.find(opponent_id)
        elsif Monster.exists?(opponent_id)
            Monster.find(opponent_id)
        else
            raise ArgumentError, "Invalid opponent id: #{opponent_id}"
        end
    end

    def calculate_damage(character, opponent)
        if character.total_attack > character.total_spellpower
            physical_damage(character.total_attack, character.buffed_attack, opponent.total_armor, opponent.buffed_armor, character.critical_strike_chance, character.total_critical_strike_damage, opponent.evasion, opponent.ignore_pain_chance)
        else
            magic_damage(character.total_spellpower, character.buffed_spellpower, opponent.total_magic_resistance, opponent.buffed_magic_resistance, character.critical_strike_chance, character.total_critical_strike_damage, opponent.evasion, opponent.ignore_pain_chance)
        end

        if opponent.total_attack > opponent.spellpower
            physical_damage(opponent.total_attack, opponent.buffed_attack, character.total_armor, character.buffed_armor, opponent.critical_strike_chance, opponent.total_critical_strike_damage, character.evasion, character.ignore_pain_chance)
        else
            magic_damage(opponent.total_spellpower, opponent.buffed_spellpower, character.total_magic_resistance, character.buffed_magic_resistance, opponent.critical_strike_chance, opponent.total_critical_strike_damage, character.evasion, character.ignore_pain_chance)
        end
    end

    def physical_damage(total_attack, buffed_attack, total_armor, buffed_armor, total_critical_strike_chance, total_critical_strike_damage, evasion, ignore_pain_chance)
        # Check for a critical hit based on critical_strike_chance
        if rand(0.0..100) <= total_critical_strike_chance
        damage = ((total_attack + buffed_attack) * total_critical_strike_damage) - (total_armor + buffed_armor)
        else
        damage = (total_attack + buffed_attack) - (total_armor + buffed_armor)
        end

        # Apply damage reduction based on ignore_pain_chance
        if rand(0.0..100) <= ignore_pain_chance
        damage *= 0.8  # Reduce incoming damage by 20%
        end

        # Chance to evade damage
        if rand(0.0..100) <= evasion
        damage = 0 
        end

        damage
    end

    def magic_damage(total_spellpower, buffed_spellpower, total_magic_resistance, buffed_magic_resistance, total_critical_strike_chance, total_critical_strike_damage, evasion, ignore_pain_chance)
        # Check for a critical hit based on critical_strike_chance
        if rand(0.0..100) <= total_critical_strike_chance
        damage = ((total_spellpower + buffed_spellpower) * total_critical_strike_damage) - (total_magic_resistance + buffed_magic_resistance)
        else
        damage = (total_spellpower + buffed_spellpower) - (total_magic_resistance + buffed_magic_resistance)
        end

        # Apply damage reduction based on ignore_pain_chance
        if rand(0.0..100) <= ignore_pain_chance
        damage *= 0.8  # Reduce incoming damage by 20%
        end

        # Chance to evade damage
        if rand(0.0..100) <= evasion
        damage = 0 
        end

        damage
    end

    def character_turn
        deal_damage(@character, @opponent)
        @character.apply_trigger_skills if @character.took_damage
        @character.took_damage = false
    end

    def opponent_turn
        deal_damage(@opponent, @character)
        @opponent.apply_trigger_skills if @opponent.took_damage
        @opponent.took_damage = false
    end

    def deal_damage(character, opponent)
        damage = calculate_damage(character, opponent)

        if @character_turn == true
            @opponent.health -= damage
            @opponent.health = [@opponent.health, 0].max
            @opponent.took_damage = true if damage.positive?  
        elsif @opponent_turn == true
            @character.health -= damage
            @character.health = [@character.health, 0].max
            @character.took_damage = true if damage.positive?   
        end
    end
    
end

