class CombatController < ApplicationController

    def pve_combat
        @hunt = Hunt.find(params[:id])
        @selected_character = current_user.selected_character
        @monster = Monster.find(@hunt.monster_id)

        # Initialize combat result variables
        @combat_log = []
        @combat_result = nil

        # Combat loop
        max_turns = 50 # Set a maximum number of turns
        turn_count = 0

        while @selected_character.health.positive? && @monster.health.positive? && turn_count < max_turns
            # Character attacks monster
            character_turn(@selected_character, @monster)
            log_turn_results(@selected_character, @monster)

            # Check if monster is defeated
            break unless @monster.health.positive?

            # Monster attacks character
            monster_turn(@selected_character, @monster)
            log_turn_results(@selected_character, @monster)

            turn_count += 1
        end

        # Set combat result variables based on the outcome
        @combat_result = @selected_character.health.positive? ? 'victory' : 'defeat'

        # Render combat result view
        render 'combat_result'
    end

    private

    def character_turn(selected_character, monster)
        damage = calculate_damage(
            selected_character.attack,
            monster.armor,
            selected_character.critical_strike_chance,
            selected_character.ignore_pain_chance
        )
        monster.health -= damage
    end

    def monster_turn(selected_character, monster)
        damage = calculate_damage(
            monster.attack,
            selected_character.armor,
            0,  # Setting critical_strike_chance to 0 for monsters
            0   # Setting ignore_pain_chance to 0 for monsters
            )
        selected_character.health -= damage
    end

    def calculate_damage(attack, armor, critical_strike_chance, ignore_pain_chance)
        # Check for a critical hit based on critical_strike_chance (which represents a percentage chance)
        if rand(0..10000) / 100.0 <= critical_strike_chance
            critical_damage = attack * 1.5  # Adjust the critical hit multiplier as needed
            damage = [critical_damage - armor, 0].max
        else
            normal_damage = attack - armor
            damage = [normal_damage, 0].max
        end

        # Apply damage reduction based on ignore_pain_chance
        if rand(0..10000) / 100.0 <= ignore_pain_chance
            reduced_damage = damage * 0.8  # Reduce incoming damage by 20%
        else
            damage
        end
    end

    def log_turn_results(selected_character, monster)
        character_damage = calculate_damage(selected_character.attack, monster.armor, selected_character.critical_strike_chance, selected_character.ignore_pain_chance)
        monster_damage = calculate_damage(monster.attack, selected_character.armor, 0, 0)

        character_attack = "#{selected_character.character_name} attacks #{monster.monster_name} for #{character_damage} damage"
        character_attack += " - CRITICAL STRIKE" if selected_character.critical_strike_chance && character_damage > selected_character.attack - monster.armor
        character_attack += " - IGNORE PAIN" if selected_character.ignore_pain_chance && character_damage < selected_character.attack - monster.armor
        character_attack += " - (#{monster.monster_name} health: #{[monster.health - character_damage, 0].max})."

        monster_attack = "#{monster.monster_name} attacks #{selected_character.character_name} for #{monster_damage} damage"
        monster_attack += " - (#{selected_character.character_name} health: #{[selected_character.health - monster_damage, 0].max})."

        if selected_character.health <= 0
            defeat_message = ["#{monster.monster_name} has defeated #{selected_character.character_name}"]
            @combat_log << defeat_message
        elsif monster.health <= 0
            victory_message = ["#{selected_character.character_name} has defeated #{monster.monster_name}"]
            @combat_log << victory_message
        else
            @combat_log << [character_attack, monster_attack]
        end
    end
    
end

