class CombatController < ApplicationController

    def combat
        @character = current_user.selected_character
        @opponent = determine_opponent
        @hunt = @selected_character.accepted_hunt
        
        # Initialize combat result variables
        @turn_number = 0
        @combat_log = []
        @combat_result = nil

        # Combat loop
        while @character.health.positive? && @opponent.health.positive?
            @turn_number += 1
            # Character attacks opponent
            character_turn(@opponent)
            # Check if opponent is defeated
            break unless @opponent.health.positive?
            # Opponent attacks character
            opponent_turn(@character)
            # Check if character is defeated
            break unless @character.health.positive?
        end

        @combat_log.map! { |entry| entry.is_a?(Array) ? entry : [entry] }

        # Set combat result variables based on the outcome
        @combat_result = @character.health.positive? ? 'victory' : 'defeat'

        # Render combat result view if the combat loop is finished
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

    def physical_damage(attack, armor, critical_strike_chance, critical_strike_damage, evasion, ignore_pain_chance)
        # Check for a critical hit based on critical_strike_chance
        if rand(0..100) <= critical_strike_chance
        damage = (attack * critical_strike_damage) - armor
        else
        damage = attack - armor
        end

        # Apply damage reduction based on ignore_pain_chance
        if rand(0..100) <= ignore_pain_chance
        damage *= 0.8  # Reduce incoming damage by 20%
        end

        # Chance to evade damage
        damage = 0 if rand(0..100) <= evasion

        damage
    end

    def magic_damage(spellpower, magic_resistance, critical_strike_chance, critical_strike_damage, evasion, ignore_pain_chance)
        # Check for a critical hit based on critical_strike_chance
        if rand(0..100) <= critical_strike_chance
        damage = (spellpower * critical_strike_damage) - magic_resistance
        else
        damage = spellpower - magic_resistance
        end

        # Apply damage reduction based on ignore_pain_chance
        if rand(0..100) <= ignore_pain_chance
        damage *= 0.8  # Reduce incoming damage by 20%
        end

        # Chance to evade damage
        damage = 0 if rand(0..100) <= evasion

        damage
    end

    def character_turn(opponent)
        damage = calculate_damage(@character, @opponent)
        @opponent.health -= damage

        log_entry = "Turn #{@turn_number}: "
        if @opponent.is_a?(Character)
            log_entry += "#{@character.character_name} attacked #{@opponent.character_name}"
        elsif @opponent.is_a?(Monster)
            log_entry += "#{@character.character_name} attacked #{@opponent.monster_name}"
        end

        log_entry += " for #{damage} damage." if damage > 0
        @combat_log << log_entry
    end

    def opponent_turn(character)
        damage = calculate_damage(@opponent, @character)
        @character.health -= damage

        log_entry = "Turn #{@turn_number}: "
        if @opponent.is_a?(Character)
            log_entry += "#{@opponent.character_name} attacked #{@character.character_name}"
        elsif @opponent.is_a?(Monster)
            log_entry += "#{@opponent.monster_name} attacked #{@character.character_name}"
        end

        log_entry += " for #{damage} damage." if damage > 0
        @combat_log << log_entry
    end

    def calculate_damage(character, opponent)
        if character.attack > character.spellpower
            physical_damage(character.attack, opponent.armor, character.critical_strike_chance, character.critical_strike_damage, opponent.evasion, opponent.ignore_pain_chance)
        else
            magic_damage(character.spellpower, opponent.magic_resistance, character.critical_strike_chance, character.critical_strike_damage, opponent.evasion, opponent.ignore_pain_chance)
        end

        if opponent.attack > opponent.spellpower
            physical_damage(opponent.attack, character.armor, opponent.critical_strike_chance, opponent.critical_strike_damage, character.evasion, character.ignore_pain_chance)
        else
            magic_damage(opponent.spellpower, character.magic_resistance, opponent.critical_strike_chance, opponent.critical_strike_damage, character.evasion, character.ignore_pain_chance)
        end
    end

end

