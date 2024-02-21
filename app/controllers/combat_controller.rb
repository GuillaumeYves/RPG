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
        @opponent = determine_opponent
        @character = current_user.selected_character
        @hunt = @character.accepted_hunt
        @combat_logs = params[:combat_logs] || []
        @combat_result = params[:combat_result]
    end

    def switch_turns
        @character_turn = !@character_turn
        @opponent_turn = !@opponent_turn
    end

    def combat
        @character = current_user.selected_character
        @opponent = determine_opponent
        @hunt = @character.accepted_hunt

        # Randomly determine the first turn
        @character_turn = rand(2).zero?
        @opponent_turn = !@character_turn

        # Initialize combat
        @combat_result = nil
        @combat_logs = []
        @turn_count = 1
        @character.piety = false
        @opponent.piety = false if @opponent.is_a?(Character)
        @character.nullify = false
        @opponent.nullify = false if @opponent.is_a?(Character)
        @character.took_damage = false
        @opponent.took_damage = false if @opponent.is_a?(Character)

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

        while @character.total_health.positive? && @opponent.total_health.positive?
            # Character's turn
            if @character_turn
            character_turn    
            # Opponent's turn
            elsif @opponent_turn
            opponent_turn
            end
            switch_turns

            if @character.total_health.positive? && @opponent.total_health.positive?
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
            unless @character.total_health.positive? && @opponent.total_health.positive?
                break
            end
        end

        # Set combat result based on the outcome
        @combat_result = if @character.total_health.positive?
                            '<strong style="font-size: 18px;">Victory</strong>'
                        elsif @opponent.total_health.positive?
                            '<strong style="font-size: 18px;">Defeat</strong>'
                        end
        log_message =  "#{@combat_result}"
        @combat_logs << log_message

        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats
        
        redirect_to combat_result_path(character_id: @character.id, opponent_id: @opponent.id, combat_logs: @combat_logs, combat_result: @combat_result)
    end

    def physical_damage(total_attack, buffed_attack, total_armor, buffed_armor, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, evasion, ignore_pain_chance)
        @is_crit = false
        
        # Check for a critical hit based on critical_strike_chance
        if rand(0.0..100.0) <= (total_critical_strike_chance + buffed_critical_strike_chance)
                damage = ((total_attack + buffed_attack) * (total_critical_strike_damage + buffed_critical_strike_damage >= 1.0 ? total_critical_strike_damage + buffed_critical_strike_damage: 1.0)) - (total_armor + buffed_armor)
            log_message = '<span style="color: red; text-shadow: 1px 1px 2px #000000;">CRITICAL STRIKE</span>'
            @combat_logs << log_message
            @is_crit = true
        else
            damage = (total_attack + buffed_attack) - (total_armor + buffed_armor)
            
            # Apply damage reduction based on ignore_pain_chance
            if rand(0.0..100.0) <= ignore_pain_chance
                damage *= 0.8  # Reduce incoming damage by 20%
            log_message = '<span style="color: blue; text-shadow: 1px 1px 2px #000000;">IGNORE PAIN</span>'
            @combat_logs << log_message
            end

            # Chance to evade damage
            if rand(0.0..100.0) <= evasion
                damage = 0 
            log_message = '<span style="color: yellow; text-shadow: 1px 1px 2px #000000;">EVADED</span>'
            @combat_logs << log_message
            end
        end

        damage
    end

    def magic_damage(total_spellpower, buffed_spellpower, total_magic_resistance, buffed_magic_resistance, total_critical_strike_chance, buffed_critical_strike_chance, total_critical_strike_damage, buffed_critical_strike_damage, evasion, ignore_pain_chance)
        @is_crit = false
        # Check for a critical hit based on critical strike chance
        if rand(0.0..100.0) <= (total_critical_strike_chance + buffed_critical_strike_chance)
            damage = ((total_spellpower + buffed_spellpower) * (total_critical_strike_damage + buffed_critical_strike_damage >= 1.0 ? total_critical_strike_damage + buffed_critical_strike_damage : 1.0)) - (total_magic_resistance + buffed_magic_resistance)
            log_message = '<span style="color: red; text-shadow: 1px 1px 2px #000000;">CRITICAL STRIKE</span>'
            @combat_logs << log_message
            @is_crit = true
        else
            damage = (total_spellpower + buffed_spellpower) - (total_magic_resistance + buffed_magic_resistance)

            # Apply damage reduction based on ignore_pain_chance
            if rand(0.0..100.0) <= ignore_pain_chance
                damage *= 0.8  # Reduce incoming damage by 20%
            log_message = '<span style="color: blue; text-shadow: 1px 1px 2px #000000;">IGNORE PAIN</span>'
            @combat_logs << log_message
            end

            # Chance to evade damage
            if rand(0.0..100.0) <= evasion
                damage = 0 
            log_message = '<span style="color: yellow; text-shadow: 1px 1px 2px #000000;">EVADED</span>'
            @combat_logs << log_message
            end
        end

        damage.round
    end

    def character_turn
        if @character.took_damage == true
            @character.apply_trigger_skills
            if @character.skills.find_by(name: 'Surge of Light', unlocked: true).present?
                surge_of_light = (@character.total_max_health * 0.02).round
                @character.total_health += surge_of_light
                log_message = "#{@character.character_name} recovered <strong>#{surge_of_light}</strong> Health with 'Surge of Light' "
                log_message += "- #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
                @combat_logs << log_message
            end
        end

        if @character.skills.find_by(name: 'Piety', unlocked: true).present? && (@character.total_health <= (0.5 * @character.total_max_health)) && @character.piety == false
            piety = (@character.total_max_health * 0.20).round
            @character.total_health += piety
            @character.piety == true
            log_message = "#{@character.character_name} recovered <strong>#{piety}</strong> Health with 'Piety' "
            log_message += "- #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
            @combat_logs << log_message
        end

        deal_damage(@character, @opponent)
        @character.apply_combat_skills
        @character.took_damage = false
    end

    def opponent_turn
        if @opponent.took_damage == true && @opponent.is_a?(Character)
            @opponent.apply_trigger_skills
            if @opponent.skills.find_by(name: 'Surge of Light', unlocked: true).present?
                surge_of_light = (@opponent.total_max_health * 0.02).round
                @opponent.total_health += surge_of_light
                log_message = "#{@opponent.character_name} recovered <strong>#{surge_of_light}</strong> Health with 'Surge of Light' "
                log_message += "- #{@opponent.character_name} : #{@opponent.total_health} / #{@opponent.total_max_health} Health "
                @combat_logs << log_message
            end
        end

        if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Piety', unlocked: true).present? && (@opponent.total_health <= (0.5 * @opponent.total_max_health)) && @opponent.piety == false
            piety = (@opponent.total_max_health * 0.20).round
            @opponent.total_health += piety
            @opponent.piety == true
            log_message = "#{@opponent.character_name} recovered <strong>#{piety}</strong> Health with 'Piety' "
            log_message += "- #{@opponent.character_name} : #{@opponent.total_health} / #{@opponent.total_max_health} Health "
            @combat_logs << log_message
        end

        deal_damage(@opponent, @character)
        @opponent.apply_combat_skills if @opponent.is_a?(Character)
        @opponent.took_damage = false
    end

    def deal_damage(character, opponent)
        if @character_turn
            if @character.total_attack >= @character.total_spellpower
                damage = [physical_damage(@character.total_attack, @character.buffed_attack, @opponent.total_armor, @opponent.buffed_armor, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @opponent.evasion, @opponent.ignore_pain_chance).round, 0].max
            elsif @character.total_spellpower > @character.total_attack
                damage = [magic_damage(@character.total_spellpower, @character.buffed_spellpower, @opponent.total_magic_resistance, @opponent.buffed_magic_resistance, @character.total_critical_strike_chance, @character.buffed_critical_strike_chance, @character.total_critical_strike_damage, @character.buffed_critical_strike_damage, @opponent.evasion, @opponent.ignore_pain_chance).round, 0].max
            end 

            if damage.positive?
                @opponent.total_health -= damage
                log_message = "#{@character.character_name} attacked for <strong>#{damage}</strong> damage "

            if rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                sharpened_blade = ((@character.total_attack + @character.buffed_attack) * 0.5).round
                @opponent.total_health -= (sharpened_blade - (@opponent.total_armor + @opponent.buffed_armor))
                log_message += ", <strong>#{sharpened_blade}</strong> physical damage with 'Sharpened Blade' "
            elsif rand(0.0..100.0) <= 30.0 && @character.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                poisoned_blade = ((@character.total_attack + @character.buffed_attack) * 0.5).round
                @opponent.total_health -= (poisoned_blade - (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance))
                log_message += ", <strong>#{poisoned_blade}</strong> magic damage with 'Poisoned Blade' "
            end

            if @is_crit == true && @character.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                from_the_shadows = (damage * 0.1).round
                @opponent.total_health -= from_the_shadows
                log_message += ", <strong>#{from_the_shadows}</strong> true damage with 'From the Shadows' "
            end

            if @character.skills.find_by(name: 'Judgement', unlocked: true).present?
                judgement = (damage * 0.05).round
                @opponent.total_health -= judgement
                log_message += ", <strong>#{judgement}</strong> true damage with 'Judgement' "
            end

                @opponent.total_health = [@opponent.total_health, 0].max
                @opponent.took_damage = true if damage.positive?

            if @opponent.is_a?(Character) && @opponent.total_health == 0 && @opponent.skills.find_by(name: 'Nullify', unlocked: true).present? && @opponent.nullify == false
                @opponent.total_health += 1
                @opponent.nullify = true
                log_message += ". #{@opponent.character_name} has triggered 'Nullify' " if @opponent.nullify == true
            end

            if @opponent.is_a?(Character)
                log_message += "- #{@opponent.character_name} : #{@opponent.total_health} / #{@opponent.total_max_health} Health "
            elsif @opponent.is_a?(Monster)
                log_message += "- #{@opponent.monster_name} : #{@opponent.total_health} / #{@opponent.total_max_health} Health "
            end

                @combat_logs << log_message
            
            else
                log_message = "#{@character.character_name} dealt no damage "
                @combat_logs << log_message
            end
        
        elsif @opponent_turn
            if @opponent.total_attack >= @opponent.total_spellpower
            damage = [physical_damage(@opponent.total_attack, @opponent.buffed_attack, @character.total_armor, @character.buffed_armor, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @character.evasion, @character.ignore_pain_chance).round, 0].max
            elsif @opponent.total_spellpower > @opponent.total_attack
            damage = [magic_damage(@opponent.total_spellpower, @opponent.buffed_spellpower, @character.total_magic_resistance, @character.buffed_magic_resistance, @opponent.total_critical_strike_chance, @opponent.buffed_critical_strike_chance, @opponent.total_critical_strike_damage, @opponent.buffed_critical_strike_damage, @character.evasion, @character.ignore_pain_chance).round, 0].max
            end 

            if damage.positive?
            if @opponent.is_a?(Character)
                    @character.total_health -= damage
                log_message = "#{@opponent.character_name} attacked for <strong>#{damage}</strong> damage "
            elsif @opponent.is_a?(Monster)
                    @character.total_health -= damage
                log_message = "#{@opponent.monster_name} attacked for <strong>#{damage}</strong> damage "
            end
            
            if rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?
                sharpened_blade = ((@opponent.total_attack + @opponent.buffed_attack) * 0.5).round
                @character.total_health -= (sharpened_blade - (@character.total_armor + @character.buffed_armor))
                log_message += ", <strong>#{sharpened_blade}</strong> physical damage with 'Sharpened Blade' "
            elsif rand(0.0..100.0) <= 30.0 && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?
                poisoned_blade = ((@opponent.total_attack + @opponent.buffed_attack) * 0.5).round
                @character.total_health -= (poisoned_blade - (@character.total_magic_resistance + @character.buffed_magic_resistance))
                log_message += ", <strong>#{poisoned_blade}</strong> magic damage with 'Poisoned Blade' "
            end
            
            if @is_crit == true && @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'From the Shadows', unlocked: true).present?
                from_the_shadows = (damage * 0.1).round
                @character.total_health -= from_the_shadows
                log_message += ", <strong>#{from_the_shadows}</strong> true damage with 'From the Shadows' "
            end

            if @opponent.is_a?(Character) && @opponent.skills.find_by(name: 'Judgement', unlocked: true).present?
                judgement = (damage * 0.05).round
                @character.total_health -= judgement
                log_message += ", <strong>#{judgement}</strong> true damage with 'Judgement' "
            end

            @character.total_health = [@character.total_health, 0].max
            @character.took_damage = true if damage.positive? 

            if @character.total_health == 0 && @character.skills.find_by(name: 'Nullify', unlocked: true).present? && @character.nullify == false
                @character.total_health += 1
                @character.nullify = true
                log_message += ". #{@character.character_name} has triggered 'Nullify' " if @character.nullify == true
            end

            log_message += "- #{@character.character_name} : #{@character.total_health} / #{@character.total_max_health} Health "
            @combat_logs << log_message
            end
        end
    end

end

