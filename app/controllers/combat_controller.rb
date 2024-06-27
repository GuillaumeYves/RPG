class CombatController < ApplicationController
    def initialize_combat_variables
        @result = nil
        @combat_logs = []
        @turn_count = 1

        @character_has_missed = false
        @character_has_evaded = false
        @character_has_crit = false
        @character_has_ignored_pain = false
        @character_has_blocked = false

        @opponent_has_missed = false
        @opponent_has_evaded = false
        @opponent_has_crit = false
        @opponent_has_ignored_pain = false
        @opponent_has_blocked = false

        @character.piety = false
        @opponent.piety = false
        @character.nullify = false
        @opponent.nullify = false
        @character.ephemeral_rebirth = false
        @opponent.ephemeral_rebirth = false
        @character.blessing_of_kings = false
        @opponent.blessing_of_kings = false
        @character.deathsbargain = false
        @opponent.deathsbargain = false
        @character.took_damage = false
        @opponent.took_damage = false

        @opponent_health_in_combat = @opponent.total_health.to_i

        @character_attack = (@character.total_min_attack + @character.total_max_attack).to_i
        @character_spellpower = (@character.total_min_spellpower + @character.total_max_spellpower).to_i
        @character_necrosurge = (@character.total_min_necrosurge + @character.total_max_necrosurge).to_i
        @character_critical_strike_chance = (@character.total_critical_strike_chance + @character.buffed_critical_strike_chance).to_d
        @character_critical_strike_damage = (@character.total_critical_strike_damage + @character.buffed_critical_strike_damage).to_d
        @character_armor = (@character.total_armor + @character.buffed_armor).to_i
        @character_magic_resistance = (@character.total_magic_resistance + @character.buffed_magic_resistance).to_i
        @character_critical_resistance = (@character.total_critical_resistance + @character.buffed_critical_resistance).to_i
        @character_damage_reduction = (@character.total_damage_reduction + @character.buffed_damage_reduction).to_d
        @character_fire_resistance = (@character.total_fire_resistance + @character.buffed_fire_resistance).to_i
        @character_cold_resistance = (@character.total_cold_resistance + @character.buffed_cold_resistance).to_i
        @character_lightning_resistance = (@character.total_lightning_resistance + @character.buffed_lightning_resistance).to_i
        @character_poison_resistance = (@character.total_lightning_resistance + @character.buffed_poison_resistance).to_i

        @opponent_attack = (@opponent.total_min_attack + @opponent.total_max_attack).to_i
        @opponent_spellpower = (@opponent.total_min_spellpower + @opponent.total_max_spellpower).to_i
        @opponent_necrosurge = (@opponent.total_min_necrosurge + @opponent.total_max_necrosurge).to_i
        @opponent_critical_strike_chance = (@opponent.total_critical_strike_chance + @opponent.buffed_critical_strike_chance).to_d
        @opponent_critical_strike_damage = (@opponent.total_critical_strike_damage + @opponent.buffed_critical_strike_damage).to_d
        @opponent_armor = (@opponent.total_armor + @opponent.buffed_armor).to_i
        @opponent_magic_resistance = (@opponent.total_magic_resistance + @opponent.buffed_magic_resistance).to_i
        @opponent_critical_resistance = (@opponent.total_critical_resistance + @opponent.buffed_critical_resistance).to_i
        @opponent_damage_reduction = (@opponent.total_damage_reduction + @opponent.buffed_damage_reduction).to_d
        @opponent_fire_resistance = (@opponent.total_fire_resistance + @opponent.buffed_fire_resistance).to_i
        @opponent_cold_resistance = (@opponent.total_cold_resistance + @opponent.buffed_cold_resistance).to_i
        @opponent_lightning_resistance = (@opponent.total_lightning_resistance + @opponent.buffed_lightning_resistance).to_i
        @opponent_poison_resistance = (@opponent.total_lightning_resistance + @opponent.buffed_poison_resistance).to_i

        @character_deep_wounds_turn = 0
        @opponent_deep_wounds_turn = 0
        @character_blessing_of_kings_turn = 0
        @opponent_blessing_of_kings_turn = 0
        @character_river_of_blood_stack = 0
        @opponent_river_of_blood_stack = 0
    end

    def reset_buffed_stats
        @character.set_default_values_for_buffed_stats
        @opponent.set_default_values_for_buffed_stats
    end

    def determine_opponent
        @character = current_user.selected_character
        opponent_id = params[:opponent_id].to_i
        if Character.exists?(opponent_id) && opponent_id.to_i != current_user.selected_character.id
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
    end

    def switch_turns
        @character_turn = !@character_turn
        @opponent_turn = !@opponent_turn
    end

    def combat_loop
        log_message =  "<span style='font-size: larger;'><strong>Turn #{@turn_count}</strong></span>"
            if @character_turn
                log_message += ": <span style='font-size: larger;'><strong>#{@character.character_name.upcase}</strong></span>"
            elsif @opponent_turn
                log_message += ": <span style='font-size: larger;'><strong>#{@opponent.character_name.upcase}</strong></span>"
            end
        @combat_logs << log_message
        while @character.total_health.positive? && @opponent_health_in_combat.positive?
            if @character_turn
                character_turn
            elsif @opponent_turn
                opponent_turn
            end
            switch_turns
            if @character.total_health.positive? && @opponent_health_in_combat.positive?
                @turn_count += 1
                log_message =  "<span style='font-size: larger;'><strong>Turn #{@turn_count}</strong></span>"
                if @character_turn
                    log_message += ": <span style='font-size: larger;'><strong>#{@character.character_name.upcase}</strong></span>"
                elsif @opponent_turn
                    log_message += ": <span style='font-size: larger;'><strong>#{@opponent.character_name.upcase}</strong></span>"
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
        # Default values for buffs
        reset_buffed_stats
        # Initialize combat
        initialize_combat_variables
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

    def calculate_damage(damage_type)
        if @character_turn
            case damage_type
                when :physical
                    if (@character.neck.present? && @character.neck.name == "The Nexus")
                        damage_roll = @character_attack
                    else
                        damage_roll = rand((@character.total_min_attack + @character.buffed_min_attack)..(@character.total_max_attack + @character.buffed_max_attack))
                    end
                    if (rand(0..100) <= @character_critical_strike_chance)
                        damage =  ((damage_roll + (damage_roll * @character.total_global_damage)) + (damage_roll * @character_critical_strike_damage))
                        @character_has_crit = true
                    else
                        damage = (damage_roll + (damage_roll * @character.total_global_damage))
                    end
                    if (@character.main_hand.present? && @character.main_hand.name == "Nemesis" && @opponent_health_in_combat >= (@opponent.total_max_health * 0.70))
                        damage = [(damage * 1.5), 0].max
                    end
                    if ((rand(0..100) <= 15) && @character.skills.find_by(name: "Divine Strength", unlocked: true).present?)
                        damage = [(damage * 2), 0].max
                    end
                when :magic
                    if (@character.neck.present? && @character.neck.name == "The Nexus")
                        damage_roll = @character_spellpower
                    else
                        damage_roll = rand((@character.total_min_spellpower + @character.buffed_min_spellpower)..(@character.total_max_spellpower + @character.buffed_max_spellpower))
                    end
                    if (rand(0..100) <= @character_critical_strike_chance)
                        damage =  ((damage_roll + (damage_roll * @character.total_global_damage)) + (damage_roll * @character_critical_strike_damage))
                        @character_has_crit = true
                    else
                        damage = (damage_roll + (damage_roll * @character.total_global_damage))
                    end
                    if (@character.main_hand.present? && @character.main_hand.name == "Nemesis" && @opponent_health_in_combat >= (@opponent.total_max_health * 0.70))
                        damage = [(damage * 1.5), 0].max
                    end
                    if ((rand(0..100) <= 15) && @character.skills.find_by(name: "Divine Strength", unlocked: true).present?)
                        damage = [(damage * 2), 0].max
                    end
                when :shadow
                    if (@character.neck.present? && @character.neck.name == "The Nexus")
                        damage_roll = @character_necrosurge
                    else
                        damage_roll = rand((@character.total_min_necrosurge + @character.buffed_min_necrosurge)..(@character.total_max_necrosurge + @character.buffed_max_necrosurge))
                    end
                        damage = (damage_roll + (damage_roll * @character.total_global_damage))
                    if (@character.main_hand.present? && @character.main_hand.name == "Nemesis" && @opponent_health_in_combat >= (@opponent.total_max_health * 0.70))
                        damage = [(damage * 1.5), 0].max
                    end
                    if ((rand(0..100) <= 15) && @character.skills.find_by(name: "Divine Strength", unlocked: true).present?)
                        damage = [(damage * 2), 0].max
                    end
            end
            damage = calculate_damage_mitigation(damage, damage_type)
        elsif @opponent_turn
            case damage_type
                when :physical
                    if (@opponent.neck.present? && @opponent.neck.name == "The Nexus")
                        damage_roll = @opponent_attack
                    else
                        damage_roll = rand((@opponent.total_min_attack + @opponent.buffed_min_attack)..(@opponent.total_max_attack + @opponent.buffed_max_attack))
                    end
                    if (rand(0..100) <= @opponent_critical_strike_chance)
                        damage =  ((damage_roll + (damage_roll * @opponent.total_global_damage)) + (damage_roll * @opponent_critical_strike_damage))
                        @opponent_has_crit = true
                    else
                        damage = (damage_roll + (damage_roll * @opponent.total_global_damage))
                    end
                    if (@opponent.main_hand.present? && @opponent.main_hand.name == "Nemesis" && @character.total_health >= (@character.total_max_health * 0.70))
                        damage = [(damage * 1.5), 0].max
                    end
                    if ((rand(0..100) <= 15) && @opponent.skills.find_by(name: "Divine Strength", unlocked: true).present?)
                        damage = [(damage * 2), 0].max
                    end
                when :magic
                    if (@opponent.neck.present? && @opponent.neck.name == "The Nexus")
                        damage_roll = @opponent_spellpower
                    else
                        damage_roll = rand((@opponent.total_min_spellpower + @opponent.buffed_min_spellpower)..(@opponent.total_max_spellpower + @opponent.buffed_max_spellpower))
                    end
                    if (rand(0..100) <= @opponent_critical_strike_chance)
                        damage =  ((damage_roll + (damage_roll * @opponent.total_global_damage)) + (damage_roll * @opponent_critical_strike_damage))
                        @opponent_has_crit = true
                    else
                        damage = (damage_roll + (damage_roll * @opponent.total_global_damage))
                    end
                    if (@opponent.main_hand.present? && @opponent.main_hand.name == "Nemesis" && @character.total_health >= (@character.total_max_health * 0.70))
                        damage = [(damage * 1.5), 0].max
                    end
                    if ((rand(0..100) <= 15) && @opponent.skills.find_by(name: "Divine Strength", unlocked: true).present?)
                        damage = [(damage * 2), 0].max
                    end
                when :shadow
                    if (@opponent.neck.present? && @opponent.neck.name == "The Nexus")
                        damage_roll = @opponent_necrosurge
                    else
                        damage_roll = rand((@opponent.total_min_necrosurge + @opponent.buffed_min_necrosurge)..(@opponent.total_max_necrosurge + @opponent.buffed_max_necrosurge))
                    end
                        damage = (damage_roll + (damage_roll * @opponent.total_global_damage))
                    if (@opponent.main_hand.present? && @opponent.main_hand.name == "Nemesis" && @character.total_health >= (@character.total_max_health * 0.70))
                        damage = [(damage * 1.5), 0].max
                    end
                    if ((rand(0..100) <= 15) && @opponent.skills.find_by(name: "Divine Strength", unlocked: true).present?)
                        damage = [(damage * 2), 0].max
                    end
            end
            damage = calculate_damage_mitigation(damage, damage_type)
        end
        [damage.to_i, 0].max
    end

    def calculate_damage_mitigation(damage, damage_type)
        if @character_turn
            case damage_type
                when :physical
                    unless (@character.feet.present? && @character.feet.name == "Voidwalkers")
                        damage -= @opponent_armor
                    end
                    if @character_has_crit == true
                        damage -= (@opponent_critical_resistance)
                    end
                    damage -= (damage * @opponent_damage_reduction)
                    if (rand(0..100) <= @opponent.ignore_pain_chance)
                        damage *= 0.8
                        @opponent_has_ignored_pain = true
                    elsif (@character.skills.find_by(name: "Forged in Battle", unlocked: true).present? && rand(0..100) <= 20)
                        @character_has_missed = true
                        damage = 0
                    elsif (rand(0..100) <= @opponent.total_block_chance)
                        @opponent_has_blocked = true
                        damage = 0
                    elsif (rand(0..100) <= @opponent.evasion && !@character.skills.find_by(name: "Undeniable", unlocked: true).present?)
                        @opponent_has_evaded = true
                        damage = 0
                    end
                when :magic
                    damage -= @opponent_magic_resistance
                    if @character_has_crit == true
                        damage -= (@opponent_critical_resistance)
                    end
                    damage -= (damage * @opponent_damage_reduction)
                    if (rand(0..100) <= @opponent.ignore_pain_chance)
                        damage *= 0.8
                        @opponent_has_ignored_pain = true
                    elsif (@character.skills.find_by(name: "Forged in Battle", unlocked: true).present? && rand(0..100) <= 20)
                        @character_has_missed = true
                        damage = 0
                    elsif (rand(0..100) <= @opponent.total_block_chance)
                        @opponent_has_blocked = true
                        damage = 0
                    end
                when :shadow
                    if @character_has_crit == true
                        damage -= (@opponent_critical_resistance)
                    end
                    damage -= (damage * @opponent_damage_reduction)
                    if (rand(0..100) <= @opponent.ignore_pain_chance)
                        damage *= 0.8
                        @opponent_has_ignored_pain = true
                    elsif (@character.skills.find_by(name: "Forged in Battle", unlocked: true).present? && rand(0..100) <= 20)
                        @character_has_missed = true
                        damage = 0
                    elsif (rand(0..100) <= @opponent.evasion && !@character.skills.find_by(name: "Undeniable", unlocked: true).present?)
                        @opponent_has_evaded = true
                        damage = 0
                    end
            end
        elsif @opponent_turn
            case damage_type
                when :physical
                    unless (@opponent.feet.present? && @opponent.feet.name == "Voidwalkers")
                        damage -= @character_armor
                    end
                    if @opponent_has_crit == true
                        damage -= @character_critical_resistance
                    end
                    damage -= (damage * (@character_damage_reduction))
                    if (rand(0..100) <= @character.ignore_pain_chance)
                        damage *= 0.8
                        @character_has_ignored_pain = true
                    elsif (@opponent.skills.find_by(name: "Forged in Battle", unlocked: true).present? && rand(0..100) <= 20)
                        @opponent_has_missed = true
                        damage = 0
                    elsif (rand(0..100) <= @character.total_block_chance)
                        @character_has_blocked = true
                        damage = 0
                    elsif (rand(0..100) <= @character.evasion && !@opponent.skills.find_by(name: "Undeniable", unlocked: true).present?)
                        @character_has_evaded = true
                        damage = 0
                    end
                when :magic
                    damage -= @character_magic_resistance
                    if @opponent_has_crit == true
                        damage -= (@character_critical_resistance)
                    end
                    damage -= (damage * @character_damage_reduction)
                    if (rand(0..100) <= @character.ignore_pain_chance)
                        damage *= 0.8
                        @character_has_ignored_pain = true
                    elsif (@opponent.skills.find_by(name: "Forged in Battle", unlocked: true).present? && rand(0..100) <= 20)
                        @opponent_has_missed = true
                        damage = 0
                    elsif (rand(0..100) <= @character.total_block_chance)
                        @character_has_blocked = true
                        damage = 0
                    end
                when :shadow
                    if @opponent_has_crit == true
                        damage -= (@character_critical_resistance)
                    end
                    damage -= (damage * @character_damage_reduction)
                    if (rand(0..100) <= @character.ignore_pain_chance)
                        damage *= 0.8
                        @character_has_ignored_pain = true
                    elsif (@opponent.skills.find_by(name: "Forged in Battle", unlocked: true).present? && rand(0..100) <= 20)
                        @opponent_has_missed = true
                        damage = 0
                    elsif (rand(0..100) <= @character.evasion && !@opponent.skills.find_by(name: "Undeniable", unlocked: true).present?)
                        @character_has_evaded = true
                        damage = 0
                    end
            end
        end
        [damage.to_i, 0].max
    end

    def log_damage(damage, damage_type, image, name)
        log_message = "#{image} #{name}: "
        if @character_turn
            if damage == 0
                if @character_has_missed
                    log_message += "❌(MISS)"
                elsif @opponent_has_evaded
                    log_message += "🚫(EVADE)"
                elsif @opponent_has_blocked
                    log_message += "⛔(BLOCK)"
                else
                    log_message += "⭕(Damage mitigated)"
                end
            else
                if @character_has_crit && @opponent_has_ignored_pain
                    log_message += "❗(CRITICAL STRIKE), 🛡️(IGNORE PAIN), <strong>#{damage}</strong> #{damage_type} damage"
                elsif @character_has_crit
                    log_message += "❗(CRITICAL STRIKE), <strong>#{damage}</strong> #{damage_type} damage"
                elsif @opponent_has_ignored_pain
                    log_message += "🛡️(IGNORE PAIN), <strong>#{damage}</strong> #{damage_type} damage"
                else
                    log_message += "<strong>#{damage}</strong> #{damage_type} damage"
                end
                @combat_logs << log_message
            end
        elsif @opponent_turn
            if damage == 0
                if @opponent_has_missed
                    log_message += "❌(MISS)"
                elsif @character_has_evaded
                    log_message += "🚫(EVADE)"
                elsif @character_has_blocked
                    log_message += "⛔(BLOCK)"
                else
                    log_message += "⭕(Damage mitigated)"
                end
            else
                if @opponent_has_crit && @character_has_ignored_pain
                    log_message += "❗(CRITICAL STRIKE), 🛡️(IGNORE PAIN), <strong>#{damage}</strong> #{damage_type} damage"
                elsif @character_has_crit
                    log_message += "❗(CRITICAL STRIKE), <strong>#{damage}</strong> #{damage_type} damage"
                elsif @opponent_has_ignored_pain
                    log_message += "🛡️(IGNORE PAIN), <strong>#{damage}</strong> #{damage_type} damage"
                else
                    log_message += "<strong>#{damage}</strong> #{damage_type} damage"
                end
                @combat_logs << log_message
            end
        end
    end

    def log_heal(heal, image, name)
        log_message = "#{image} #{name}: ❇️<strong>#{heal}</strong> Health recovered"
        @combat_logs << log_message
    end

    def trigger_after_attack(damage, damage_type, image, name)
        # Log the damage
        log_damage(damage, damage_type, image, name)
        # Heal after attacking
        heal_after_attack_talent(damage)
        heal_after_attack_item(damage)
        # Apply buffs after attacking
        buff_talent
        buff_item
        # Additional damage after attacking
        additional_damage_talent(damage)
        additional_damage_item(damage)
    end

    def basic_attack
        image = "🗡️"
        name = "Basic attack"
        if @character_turn
            # Determine the damage type
            if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                damage_type = :physical
                damage = calculate_damage(damage_type)
            elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                damage_type = :magic
                damage = calculate_damage(damage_type)
            elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                damage_type = :shadow
                damage = calculate_damage(damage_type)
            end
            @opponent_health_in_combat -= [damage, 0].max
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if damage.positive?
            trigger_after_attack(damage, damage_type, image, name)
        elsif @opponent_turn
            # Determine the damage type
            if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                damage_type = :physical
                damage = calculate_damage(damage_type)
            elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                damage_type = :magic
                damage = calculate_damage(damage_type)
            elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                damage_type = :shadow
                damage = calculate_damage(damage_type)
            end
            @character.total_health -= [damage, 0].max
            # Character took damage is now true if damage is positive
            @character.took_damage = true if damage.positive?
            trigger_after_attack(damage, damage_type, image, name)
        end
    end

    def extra_attack_talent
        if @character_turn
          ### Nightstalker:
            # Swift Movements
            if ((@character.skills.find_by(name: "Swift Movements", unlocked: true).present?) && (rand(0..5000) <= @character.agility))
                image = "<img src='/assets/nightstalker_skills/swiftmovements.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements Talent' class='log-talent-image'>"
                name = "Swift Movements"
                # Determine the damage type
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                end
                @opponent_health_in_combat -= [damage, 0].max
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if damage.positive?
                trigger_after_attack(damage, damage_type, image, name)
            end
          ### Paladin:
            # Fervor
            if ((@character.skills.find_by(name: "Fervor", unlocked: true).present?) && (rand(0..100) <= 30))
                image = "<img src='/assets/paladin_skills/fervor.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Fervor Talent' class='log-talent-image'>"
                name = "Fervor"
                # Determine the damage type
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 0.80).to_i
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 0.80).to_i
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 0.80).to_i
                end
                @opponent_health_in_combat -= [damage, 0].max
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if damage.positive?
                trigger_after_attack(damage, damage_type, image, name)
            end
        elsif @opponent_turn
          ### Nightstalker:
            # Swift Movements
            if ((@opponent.skills.find_by(name: "Swift Movements", unlocked: true).present?) && (rand(0..5000) <= @opponent.agility))
                image = "<img src='/assets/nightstalker_skills/swiftmovements.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements Talent' class='log-talent-image'>"
                name = "Swift Movements"
                # Determine the damage type
                if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                end
                @character.total_health -= [damage, 0].max
                # Opponent took damage is now true if damage is positive
                @character.took_damage = true if damage.positive?
                trigger_after_attack(damage, damage_type, image, name)
            end
          ### Paladin:
            # Fervor
            if ((@opponent.skills.find_by(name: "Fervor", unlocked: true).present?) && (rand(0..100) <= 30))
                image = "<img src='/assets/paladin_skills/fervor.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Fervor Talent' class='log-talent-image'>"
                name = "Fervor"
                # Determine the damage type
                if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 0.80).to_i
                elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 0.80).to_i
                elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 0.80).to_i
                end
                @character.total_health -= [damage, 0].max
                # Opponent took damage is now true if damage is positive
                @character.took_damage = true if damage.positive?
                trigger_after_attack(damage, damage_type, image, name)
            end
        end
    end

    def extra_attack_item
        if @character_turn
            # Havoc
            if (rand(0..100) <= 50 && (@character.main_hand.present? && @character.main_hand.name == "Havoc"))
                image = "<img src='/assets/legendary_items/havoc.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Havoc Item' class='log-item-image'>"
                name = "Havoc"
                # Determine the damage type
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                end
                @opponent_health_in_combat -= [damage, 0].max
                trigger_after_attack(damage, damage_type, image, name)
            end
            # Hellbound
            if (rand(0..100) <= 10 && (@character.main_hand.present? && @character.main_hand.name == "Hellbound"))
                image = "<img src='/assets/legendary_items/hellbound.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Havoc Item' class='log-item-image'>"
                name = "Hellbound"
                # Determine the damage type
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 1.5).to_i
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 1.5).to_i
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 1.5).to_i
                end
                @opponent_health_in_combat -= [damage, 0].max
                trigger_after_attack(damage, damage_type, image, name)
            end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if damage.positive?
        elsif @opponent_turn
            # Havoc
            if (rand(0..100) <= 50 && (@opponent.main_hand.present? && @opponent.main_hand.name == "Havoc"))
                # Determine the damage type
                if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                elsif @opponent_spellpower > @opponent_attack && @character_spellpower > @opponent_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 0.50).to_i
                end
                @character.total_health -= [damage, 0].max
                trigger_after_attack(damage, damage_type, image_name)
            end
            # Hellbound
            if (rand(0..100) <= 10 && (@opponent.main_hand.present? && @opponent.main_hand.name == "Hellbound"))
                # Determine the damage type
                if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 1.5).to_i
                elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 1.5).to_i
                elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 1.5).to_i
                end
                @character.total_health -= [damage, 0].max
                trigger_after_attack(damage, damage_type, image_name)
            end
            # Character took damage is now true if damage is positive
            @character.took_damage = true if damage.positive?
        end
    end

    def additional_damage_talent(damage)
        additional_damage = 0
        if @character_turn
          ### Nightstalker:
            # From the Shadows
            if (@character_has_crit == true && @character.skills.find_by(name: "From the Shadows", unlocked: true).present?)
                image = "<img src='/assets/nightstalker_skills/fromtheshadows.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='From the Shadows Talent' class='log-talent-image'>"
                name = "From the Shadows"
                damage_type = :true
                additional_damage = (damage * 0.25).to_i
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
          ### Warrior:
            # Skullsplitter
            if (@character_has_crit == true && @character.skills.find_by(name: "Skullsplitter", unlocked: true).present?)
                image = "<img src='/assets/warrior_skills/skullsplitter.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Skullsplitter Talent' class='log-talent-image'>"
                name = "Skullsplitter"
                damage_type = :physical
                additional_damage = (((@opponent.total_max_health * 0.10) - @opponent_armor) - (additional_damage * @opponent_damage_reduction)).to_i
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
            # Deep Wounds
            if (damage.positive? && @character.skills.find_by(name: 'Deep Wounds', unlocked:true).present?)
                image = "<img src='/assets/warrior_skills/deepwounds.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Deep Wounds Talent' class='log-talent-image'>"
                name = "Deep Wounds"
                damage_type = :physical
                if @character_deep_wounds_turn >= 1
                    @opponent_health_in_combat -= [@character_deep_wounds_damage, 0].max
                    @character_deep_wounds_turn -= 1
                    log_message = "#{image} #{name}: <strong>#{@character_deep_wounds_damage}</strong> #{damage_type} damage"
                    @combat_logs << log_message
                elsif @character_deep_wounds_turn == 0
                    @character_deep_wounds_turn = 3
                    @character_deep_wounds_damage = [(damage / 3).to_i, 0].max
                    log_message = "#{image} #{name} applied"
                    @combat_logs << log_message
                end
            end
          ### Paladin:
            # Judgement
            if @character.skills.find_by(name: "Judgement", unlocked: true).present?
                image = "<img src='/assets/paladin_skills/judgement.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Judgement Talent' class='log-talent-image'>"
                name = "Judgement"
                damage_type = :true
                additional_damage = (damage * 0.10).to_i
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if additional_damage.positive?
        elsif @opponent_turn
          ### Nightstalker:
            # From the Shadows
            if (@opponent_has_crit == true && @opponent.skills.find_by(name: "From the Shadows", unlocked: true).present?)
                image = "<img src='/assets/nightstalker_skills/fromtheshadows.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='From the Shadows Talent' class='log-talent-image'>"
                name = "From the Shadows"
                damage_type = :true
                additional_damage = (damage * 0.25).to_i
                @character.total_health -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
          ### Warrior:
            # Skullsplitter
            if (@opponent_has_crit == true && @opponent.skills.find_by(name: "Skullsplitter", unlocked: true).present?)
                image = "<img src='/assets/warrior_skills/skullsplitter.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Skullsplitter Talent' class='log-talent-image'>"
                name = "Skullsplitter"
                damage_type = :physical
                additional_damage = (((@character.total_max_health * 0.10) - @character_armor) - (additional_damage * @character_damage_reduction)).to_i
                @character.total_health -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
            # Deep Wounds
            if (damage.positive? && @opponent.skills.find_by(name: 'Deep Wounds', unlocked:true).present?)
                image = "<img src='/assets/warrior_skills/deepwounds.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Deep Wounds Talent' class='log-talent-image'>"
                name = "Deep Wounds"
                damage_type = :physical
                if @opponent_deep_wounds_turn >= 1
                    @character.total_health -= [@opponent_deep_wounds_damage, 0].max
                    @opponent_deep_wounds_turn -= 1
                    log_message = "#{image} #{name}: <strong>#{@opponent_deep_wounds_damage}</strong> #{damage_type} damage"
                    @combat_logs << log_message
                elsif @opponent_deep_wounds_turn == 0
                    @opponent_deep_wounds_turn = 3
                    @opponent_deep_wounds_damage = [(damage / 3).to_i, 0].max
                    log_message = "#{image} #{name} applied"
                    @combat_logs << log_message
                end
            end
          ### Paladin:
            # Judgement
            if @opponent.skills.find_by(name: "Judgement", unlocked: true).present?
                image = "<img src='/assets/paladin_skills/judgement.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Judgement Talent' class='log-talent-image'>"
                name = "Judgement"
                damage_type = :true
                additional_damage = (damage * 0.10).to_i
                @character.total_health -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
            # Character took damage is now true if damage is positive
            @character.took_damage = true if additional_damage.positive?
        end
    end

    def additional_damage_item(damage)
        additional_damage = 0
        if @character_turn
            # Rise of the Phoenix
            if (@character_has_crit == true && damage.positive? && (@character.chest.present? && @character.chest.name == "Rise of the Phoenix"))
                image = "<img src='/assets/legendary_items/riseofthephoenix.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Rise of the Phoenix Item' class='log-item-image'>"
                name = "Rise of the Phoenix"
                damage_type = :fire
                additional_damage = [(((damage * 0.30) - @opponent_fire_resistance) * @opponent_damage_reduction).to_i, 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
            # Ruler of Storms
            if (damage.positive? && @character.main_hand.present? && @character.main_hand.name == "Ruler of Storms") || (@character.off_hand.present? && @character.off_hand.name == "Ruler of Storms")
                image = "<img src='/assets/legendary_items/rulerofstorms.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Ruler of Storms Item' class='log-item-image'>"
                name = "Ruler of Storms"
                damage_type = :lightning
                additional_damage = [(((damage * 0.40) - @opponent_lightning_resistance) * @opponent_damage_reduction).to_i, 0].max
                @opponent_health_in_combat -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if additional_damage.positive?
        elsif @opponent_turn
            # Rise of the Phoenix
            if (@opponent_has_crit == true && damage.positive? && (@opponent.chest.present? && @opponent.chest.name == "Rise of the Phoenix"))
                image = "<img src='/assets/legendary_items/riseofthephoenix.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Rise of the Phoenix Item' class='log-item-image'>"
                name = "Rise of the Phoenix"
                damage_type = :fire
                additional_damage = [(((damage * 0.30) - @character_fire_resistance) * @character_damage_reduction).to_i, 0].max
                @character.total_health -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
            # Ruler of Storms
            if (damage.positive? && @opponent.main_hand.present? && @opponent.main_hand.name == "Ruler of Storms") || (@opponent.off_hand.present? && @opponent.off_hand.name == "Ruler of Storms")
                image = "<img src='/assets/legendary_items/rulerofstorms.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Ruler of Storms Item' class='log-item-image'>"
                name = "Ruler of Storms"
                damage_type = :lightning
                additional_damage = [(((damage * 0.40) - @character_lightning_resistance) * @character_damage_reduction).to_i, 0].max
                @character.total_health -= [additional_damage, 0].max
                log_damage(additional_damage, damage_type, image, name)
            end
            # Character took damage is now true if damage is positive
            @character.took_damage = true if additional_damage.positive?
        end
    end

    def damage_talent
        damage = 0
        if @character_turn
          ### Nightstalker:
            # Sharpened Blade
            if (rand(0..100) <= 30 && @character.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?)
                image = "<img src='/assets/nightstalker_skills/sharpenedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Sharpened Blade Talent' class='log-talent-image'>"
                name = "Sharpened Blade"
                damage_type = :physical
                damage = calculate_damage(damage_type)
                @opponent_health_in_combat -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Poisoned Blade
            if (rand(0..100) <= 30 && @character.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?)
                image = "<img src='/assets/nightstalker_skills/poisonedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Poisoned Blade Talent' class='log-talent-image'>"
                name = "Poisoned Blade"
                damage_type = :poison
                damage = calculate_damage(damage_type)
                @opponent_health_in_combat -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
            end
          ### Deathwalker:
            # Crimson Torrent
            if (@character.skills.find_by(name: "Crimson Torrent", unlocked: true).present?)
                image = "<img src='/assets/deathwalker_skills/crimsontorrent.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Crimson Torrent Talent' class='log-talent-image'>"
                name = "Crimson Torrent"
                damage_type = :shadow
                damage = (@character.total_max_health * 0.03).to_i
                @opponent_health_in_combat -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if damage.positive?
        elsif @opponent_turn
          ### Nightstalker:
            # Sharpened Blade
            if (rand(0..100) <= 30 && @opponent.skills.find_by(name: 'Sharpened Blade', unlocked: true).present?)
                name = "Sharpened Blade"
                image = "<img src='/assets/nightstalker_skills/sharpenedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Sharpened Blade Talent' class='log-talent-image'>"
                damage_type = :physical
                damage = calculate_damage(damage_type)
                @character.total_health -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Poisoned Blade
            if (rand(0..100) <= 30 && @opponent.skills.find_by(name: 'Poisoned Blade', unlocked: true).present?)
                name = "Poisoned Blade"
                image = "<img src='/assets/nightstalker_skills/poisonedblade.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Poisoned Blade Talent' class='log-talent-image'>"
                damage_type = :poison
                damage = calculate_damage(damage_type)
                @character.total_health -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
            end
          ### Deathwalker:
            # Crimson Torrent
            if (@opponent.skills.find_by(name: "Crimson Torrent", unlocked: true).present?)
                image = "<img src='/assets/deathwalker_skills/crimsontorrent.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Crimson Torrent Talent' class='log-talent-image'>"
                name = "Crimson Torrent"
                damage_type = :shadow
                damage = (@character.total_max_health * 0.03).to_i
                @character.total_health -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Character took damage is now true if damage is positive
            @character.took_damage = true if damage.positive?
        end
    end

    def damage_item
        damage = 0
        if @character_turn
            # Arcane Weavers
            if (@character.hands.present? && @character.hands.name == "Arcane Weavers")
                image = "<img src='/assets/legendary_items/arcaneweavers.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Arcane Weavers Item' class='log-item-image'>"
                name = "Arcane Weavers"
                damage_type = :magic
                damage = calculate_damage(damage_type)
                @opponent_health_in_combat -= [(damage * 0.20).to_i, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Chi No Namida
            if (@opponent.took_damage == true && ((@character.main_hand.present? && @character.main_hand.name == "Chi No Namida") || (@character.off_hand.present? && @character.off_hand.name == "Chi No Namida")))
                image = "<img src='/assets/legendary_items/chinonamida.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Chi No Namida Item' class='log-item-image'>"
                name = "Chi No Namida"
                damage_type = :physical
                @character_river_of_blood_stack += 1
                if @character_river_of_blood_stack == 6
                    @character.buffed_critical_strike_chance += 999.9
                    damage = (calculate_damage(damage_type) * 2).to_i
                    @opponent_health_in_combat -= [damage, 0].max
                    log_damage(damage, damage_type, image, name)
                    @character.buffed_critical_strike_chance -= 999.9
                    @character_river_of_blood_stack = 0
                elsif @character_river_of_blood_stack > 1
                    log_message = "#{image} #{name}: <strong>#{@character_river_of_blood_stack}</strong> Hemorrhage stacks"
                    @combat_logs << log_message
                elsif @character_river_of_blood_stack == 1
                    log_message = "#{image} #{name}: <strong>#{@character_river_of_blood_stack}</strong> Hemorrhage stack"
                    @combat_logs << log_message
                end
            end
            # Grand Arcanist Band
            if ((@character.finger1.present? && @character.finger1.name == "Grand Arcanist Band") || (@character.finger2.present? && @character.finger2.name == "Grand Arcanist Band"))
                image = "<img src='/assets/legendary_items/grandarcanistband.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Grand Arcanist Band Item' class='log-item-image'>"
                name = "Grand Arcanist Band"
                damage_type = :magic
                damage = calculate_damage(damage_type)
                @opponent_health_in_combat -= [(damage * 0.18).to_i, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Laceration
            if ((@character.main_hand.present? && @character.main_hand.name == "Laceration") || (@character.off_hand.present? && @character.off_hand.name == "Laceration"))
                image = "<img src='/assets/legendary_items/laceration.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Laceration Item' class='log-item-image'>"
                name = "Laceration"
                damage_type = :physical
                damage = calculate_damage(damage_type)
                @opponent_health_in_combat -= [(damage * 0.50).to_i, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Nethil
            if ((@character.main_hand.present? && @character.main_hand.name == "Nethil") || (@character.off_hand.present? && @character.off_hand.name == "Nethil"))
                image = "<img src='/assets/legendary_items/nethil.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Nethil Item' class='log-item-image'>"
                name = "Nethil"
                damage_type = :shadow
                damage = 333
                @opponent_health_in_combat -= [damage , 0].max
                log_damage(damage, damage_type, image, name)
                @character.total_health += [damage, (@character.total_max_health - @character.total_health)].min
                log_message = "❇️<strong>#{damage}</strong> Health recovered"
                @combat_logs << log_message
            end
            # The First Flame
            if (@character.neck.present? && @character.neck.name == "The First Flame")
                if (rand(0..100) <= 10)
                    image = "<img src='/assets/legendary_items/thefirstflame.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='The First Flame Item' class='log-item-image'>"
                    name = "The First Flame"
                    damage_type = :fire
                    damage = (((@opponent.total_max_health * 0.08) - @opponent_fire_resistance)) - (damage * @opponent_damage_reduction).to_i
                    @opponent_health_in_combat -= [damage, 0].max
                    log_damage(damage, damage_type, image, name)
                end
            end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if damage.positive?
        elsif @opponent_turn
            # Arcane Weavers
            if (@opponent.hands.present? && @opponent.hands.name == "Arcane Weavers")
                image = "<img src='/assets/legendary_items/arcaneweavers.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Arcane Weavers Item' class='log-item-image'>"
                name = "Arcane Weavers"
                damage_type = :magic
                damage = calculate_damage(damage_type)
                @character.total_health -= [(damage * 0.20).to_i, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Chi No Namida
            if (@character.took_damage == true && ((@opponent.main_hand.present? && @opponent.main_hand.name == "Chi No Namida") || (@opponent.off_hand.present? && @opponent.off_hand.name == "Chi No Namida")))
                image = "<img src='/assets/legendary_items/chinonamida.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Chi No Namida Item' class='log-item-image'>"
                name = "Chi No Namida"
                damage_type = :physical
                @opponent_river_of_blood_stack += 1
                if @opponent_river_of_blood_stack == 6
                    @opponent.buffed_critical_strike_chance += 999.9
                    damage = (calculate_damage(damage_type) * 2).to_i
                    @character.total_health -= [damage, 0].max
                    log_damage(damage, damage_type, image, name)
                    @opponent.buffed_critical_strike_chance -= 999.9
                    @opponent_river_of_blood_stack = 0
                elsif @opponent_river_of_blood_stack > 1
                    log_message = "#{image} #{name}: <strong>#{@opponent_river_of_blood_stack}</strong> Hemorrhage stacks"
                    @combat_logs << log_message
                elsif @opponent_river_of_blood_stack == 1
                    log_message = "#{image} #{name}: <strong>#{@opponent_river_of_blood_stack}</strong> Hemorrhage stack"
                    @combat_logs << log_message
                end
            end
            # Grand Arcanist Band
            if ((@opponent.finger1.present? && @opponent.finger1.name == "Grand Arcanist Band") || (@opponent.finger2.present? && @opponent.finger2.name == "Grand Arcanist Band"))
                image = "<img src='/assets/legendary_items/grandarcanistband.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Grand Arcanist Band Item' class='log-item-image'>"
                name = "Grand Arcanist Band"
                damage_type = :magic
                damage = (calculate_damage(damage_type) * 0.18).to_i
                @character.total_health -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Laceration
            if ((@opponent.main_hand.present? && @opponent.main_hand.name == "Laceration") || (@opponent.off_hand.present? && @opponent.off_hand.name == "Laceration"))
                image = "<img src='/assets/legendary_items/laceration.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Laceration Item' class='log-item-image'>"
                name = "Laceration"
                damage_type = :physical
                damage = (calculate_damage(damage_type) * 0.50).to_i
                @character.total_health -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
            end
            # Nethil
            if ((@opponent.main_hand.present? && @opponent.main_hand.name == "Nethil") || (@opponent.off_hand.present? && @opponent.off_hand.name == "Nethil"))
                image = "<img src='/assets/legendary_items/nethil.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Nethil Item' class='log-item-image'>"
                name = "Nethil"
                damage_type = :shadow
                damage = 333
                @character.total_health -= [damage, 0].max
                log_damage(damage, damage_type, image, name)
                @opponent_health_in_combat += [damage, (@opponent.total_max_health - @opponent_health_in_combat)].min
                log_message = "❇️<strong>#{damage}</strong> Health recovered"
                @combat_logs << log_message
            end
            # The First Flame
            if (@opponent.neck.present? && @opponent.neck.name == "The First Flame")
                if (rand(0..100) <= 10)
                    image = "<img src='/assets/legendary_items/thefirstflame.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='The First Flame Item' class='log-item-image'>"
                    name = "The First Flame"
                    damage_type = :fire
                    damage = (((@character.total_max_health * 0.08) - @character_fire_resistance)) - (damage * @character_damage_reduction).to_i
                    @opponent_health_in_combat -= [damage, 0].max
                    log_damage(damage, damage_type, image, name)
                end
            end
            # Opponent took damage is now true if damage is positive
            @opponent.took_damage = true if damage.positive?
        end
    end

    def damage_end_of_turn_talent
        damage = 0
        if @character_turn
          ### Deathwalker:
            # Ephemeral Rebirth
            if (@character.skills.find_by(name: "Ephemeral Rebirth", unlocked: true).present? && @character.ephemeral_rebirth == true)
                image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Ephemeral Rebirth Talent' class='log-talent-image'>"
                name = "Ephemeral Rebirth"
                damage = (@character.total_max_health * 0.10).to_i
                @character.total_health -= [damage, 0].max
                # Character took damage is now true if damage is positive
                @character.took_damage = true if damage.positive?
                log_message = "#{image} #{name}: <strong>#{damage}</strong> Health lost"
                @combat_logs << log_message
            end
        elsif @opponent_turn
          ### Deathwalker:
            # Ephemeral Rebirth
            if (@opponent.skills.find_by(name: "Ephemeral Rebirth", unlocked: true).present? && @opponent.ephemeral_rebirth == true)
                image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Ephemeral Rebirth Talent' class='log-talent-image'>"
                name = "Ephemeral Rebirth"
                damage = (@opponent.total_max_health * 0.10).to_i
                @opponent_health_in_combat -= [damage, 0].max
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if damage.positive?
                log_message = "#{image} #{name}: <strong>#{damage}</strong> Health lost"
                @combat_logs << log_message
            end
        end
    end

    def buff_item
        # Character turn
        if @character_turn
            # Eternal Rage
            if (@character.head.present? && @character.head.name == "Eternal Rage")
                item_image = "<img src='/assets/legendary_items/eternalrage.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Eternal Rage Item' class='log-item-image'>"
                item_name = "Eternal Rage"
                @character.buffed_min_attack += (@character.min_attack * 0.15)
                @character.buffed_max_attack += (@character.max_attack * 0.15)
                log_message = "#{item_image} #{item_name}: ⬆️Attack increased by <strong>15%</strong>"
                @combat_logs << log_message
            end
            # Helion
            if (@character_has_crit == true && (@character.main_hand.present? && @character.main_hand.name == "Helion") || (@character.off_hand.present? && @character.off_hand.name == "Helion"))
                item_image = "<img src='/assets/legendary_items/helion.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Helion Item' class='log-item-image'>"
                item_name = "Helion"
                @character.buffed_min_spellpower += (@character.min_spellpower * 0.20)
                @character.buffed_max_spellpower += (@character.max_spellpower * 0.20)
                log_message = "#{item_image} #{item_name}: ⬆️Spellpower increased by <strong>20%</strong>"
                @combat_logs << log_message
            end
            # Necroclasp
            if (@character.hands.present? && @character.hands.name == "Necroclasp")
                image = "<img src='/assets/legendary_items/necroclasp.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Necroclasp Item' class='log-item-image'>"
                name = "Necroclasp"
                damage = (@character.total_max_health * 0.06).to_i
                @character.total_health -= [damage, 0].max
                # Character took damage is now true if damage is positive
                @character.took_damage = true if damage.positive?
                log_message = "#{image} #{name}: <strong>#{damage}</strong> Health lost"
                @combat_logs << log_message
                @character.buffed_min_necrosurge += (@character.total_min_necrosurge * 0.03).to_i
                @character.buffed_max_necrosurge += (@character.total_max_necrosurge * 0.03).to_i
                log_message = "⬆️Necrosurge increased by <strong>3%</strong>"
                @combat_logs << log_message
            end
        # Opponent turn
        elsif @opponent_turn
            # Eternal Rage
            if (@opponent.head.present? && @opponent.head.name == "Eternal Rage")
                item_image = "<img src='/assets/legendary_items/eternalrage.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Eternal Rage Item' class='log-item-image'>"
                item_name = "Eternal Rage"
                @opponent.buffed_min_attack += (@opponent.min_attack * 0.15)
                @opponent.buffed_max_attack += (@opponent.max_attack * 0.15)
                log_message = "#{item_image} #{item_name}: ⬆️Attack increased by <strong>15%</strong>"
                @combat_logs << log_message
            end
            # Helion
            if (@opponent_has_crit == true && (@opponent.main_hand.present? && @opponent.main_hand.name == "Helion") || (@opponent.off_hand.present? && @opponent.off_hand.name == "Helion"))
                item_image = "<img src='/assets/legendary_items/helion.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Helion Item' class='log-item-image'>"
                item_name = "Helion"
                @opponent.buffed_min_spellpower += (@opponent.min_spellpower * 0.20)
                @opponent.buffed_max_spellpower += (@opponent.max_spellpower * 0.20)
                log_message = "#{item_image} #{item_name}: ⬆️Spellpower increased by <strong>20%</strong>"
                @combat_logs << log_message
            end
            # Necroclasp
            if (@opponent.hands.present? && @opponent.hands.name == "Necroclasp")
                image = "<img src='/assets/legendary_items/necroclasp.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Necroclasp Item' class='log-item-image'>"
                name = "Necroclasp"
                damage = (@opponent.total_max_health * 0.06).to_i
                @opponent_health_in_combat -= [damage, 0].max
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if damage.positive?
                log_message = "#{image} #{name}: <strong>#{damage}</strong> Health lost"
                @combat_logs << log_message
                @opponent.buffed_min_necrosurge += (@opponent.total_min_necrosurge * 0.03).to_i
                @opponent.buffed_max_necrosurge += (@opponent.total_max_necrosurge * 0.03).to_i
                log_message = "⬆️Necrosurge increased by <strong>3%</strong>"
                @combat_logs << log_message
            end
        end
    end

    def buff_talent
        if @character_turn
          ### Deathwalker:
            # Lifetap
            if (@character.skills.find_by(name: "Lifetap", unlocked: true).present?)
                image = "<img src='/assets/deathwalker_skills/lifetap.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Lifetap Talent' class='log-talent-image'>"
                name = "Lifetap"
                damage = (@character.total_max_health * 0.01).to_i
                @character.total_health -= [damage, 0].max
                # Character took damage is now true if damage is positive
                @character.took_damage = true if damage.positive?
                log_message = "#{image} #{name}: <strong>#{damage}</strong> Health lost"
                @combat_logs << log_message
                @character.buffed_min_necrosurge += damage
                @character.buffed_max_necrosurge += damage
                log_message = "⬆️Necrosurge increased by <strong>#{damage}</strong>"
                @combat_logs << log_message
            end
        elsif @opponent_turn
          ### Deathwalker:
            # Lifetap
            if (@opponent.skills.find_by(name: "Lifetap", unlocked: true).present?)
                image = "<img src='/assets/deathwalker_skills/lifetap.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Lifetap Talent' class='log-talent-image'>"
                name = "Lifetap"
                damage = (@opponent.total_max_health * 0.01).to_i
                @opponent_health_in_combat -= [damage, 0].max
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if damage.positive?
                log_message = "#{image} #{name}: <strong>#{damage}</strong> Health lost"
                @combat_logs << log_message
                @opponent.buffed_min_necrosurge += damage
                @opponent.buffed_max_necrosurge += damage
                log_message = "⬆️Necrosurge increased by <strong>#{damage}</strong>"
                @combat_logs << log_message
            end
        end
    end

    def heal_after_attack_talent(damage)
        if @character_turn
          ### Deathwalker:
            # Path of the Dead
            if (@character_has_crit == true && @character.skills.find_by(name: "Path of the Dead", unlocked: true).present?)
                image = "<img src='/assets/deathwalker_skills/pathofthedead.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Path of the Dead Talent' class='log-talent-image'>"
                name = "Path of the Dead"
                heal = (damage * 0.33).to_i
                @character.total_health += [heal, @character.total_max_health - @character.total_health].min
                log_heal(heal, image, name)
            end
        elsif @opponent_turn
          ### Deathwalker:
            # Path of the Dead
            if (@opponent_has_crit == true && @opponent.skills.find_by(name: "Path of the Dead", unlocked: true).present?)
                image = "<img src='/assets/deathwalker_skills/pathofthedead.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Path of the Dead Talent' class='log-talent-image'>"
                name = "Path of the Dead"
                heal = (damage * 0.33).to_i
                @opponent_health_in_combat += [heal, @opponent.total_max_health - @opponent_health_in_combat].min
                log_heal(heal, image, name)
            end
        end
    end

    def heal_after_attack_item(damage)
        if @character_turn
            # Well of Souls
            if (@character_has_crit == true && (@character.waist.present? && @character.waist.name == "Well of Souls"))
                image = "<img src='/assets/legendary_items/wellofsouls.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Well of Souls Item' class='log-item-image'>"
                name = "Well of Souls"
                heal = (@character.total_max_health * 0.06).to_i
                @character.total_health += [heal, @character.total_max_health - @character.total_health].min
                log_heal(heal, image, name)
            end
        elsif @opponent_turn
            # Well of Souls
            if (@opponent_has_crit == true && (@opponent.waist.present? && @opponent.waist.name == "Well of Souls"))
                image = "<img src='/assets/legendary_items/wellofsouls.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Well of Souls Item' class='log-item-image'>"
                name = "Well of Souls"
                heal = (@character.total_max_health * 0.06).to_i
                @opponent_health_in_combat += [heal, @opponent.total_max_health - @opponent_health_in_combat].min
                log_heal(heal, image, name)
            end
        end
    end

    def execute_item
        if @character_turn
            # Dawnbreaker
            if ((@character.main_hand.present? && @character.main_hand.name == "Dawnbreaker") && @opponent_health_in_combat <= (@opponent.total_max_health * 0.10))
                image = "<img src='/assets/legendary_items/dawnbreaker.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawnbreaker Item' class='log-item-image'>"
                name = "Dawnbreaker"
                # Determine the damage type
                if @character_attack > @character_spellpower && @character_attack > @character_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 1.11).to_i
                elsif @character_spellpower > @character_attack && @character_spellpower > @character_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 1.11).to_i
                elsif @character_necrosurge > @character_attack && @character_necrosurge > @character_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 1.11).to_i
                end
                @opponent_health_in_combat -= [damage, 0].max
                # Opponent took damage is now true if damage is positive
                @opponent.took_damage = true if damage.positive?
                log_damage(damage, damage_type, image, name)
            end
        elsif @opponent_turn
            # Dawnbreaker
            if ((@opponent.main_hand.present? && @opponent.main_hand.name == "Dawnbreaker") && @character.total_health <= (@character.total_max_health * 0.10))
                image = "<img src='/assets/legendary_items/dawnbreaker.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Dawnbreaker Item' class='log-item-image'>"
                name = "Dawnbreaker"
                # Determine the damage type
                if @opponent_attack > @opponent_spellpower && @opponent_attack > @opponent_necrosurge
                    damage_type = :physical
                    damage = (calculate_damage(damage_type) * 1.11).to_i
                elsif @opponent_spellpower > @opponent_attack && @opponent_spellpower > @opponent_necrosurge
                    damage_type = :magic
                    damage = (calculate_damage(damage_type) * 1.11).to_i
                elsif @opponent_necrosurge > @opponent_attack && @opponent_necrosurge > @opponent_spellpower
                    damage_type = :shadow
                    damage = (calculate_damage(damage_type) * 1.11).to_i
                end
                @character.total_health -= [damage, 0].max
                # Character took damage is now true if damage is positive
                @character.took_damage = true if damage.positive?
                log_damage(damage, damage_type, image, name)
            end
        end
    end

    def cheat_death
        if @character_turn
            # Death's Bargain
            if ((@opponent_health_in_combat <= 0 && @opponent.off_hand.present? && @opponent.off_hand.name  == "Death's Bargain") && @opponent.deathsbargain  == false)
                deathsbargain_image = "<img src='/assets/legendary_items/deathsbargain.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat = 1
                @opponent.deathsbargain = true
                log_message = "#{@opponent.character_name} has triggered #{deathsbargain_image} Death's Bargain" if @opponent.deathsbargain == true
                @combat_logs << log_message
            end
            # Nullify
            if (@opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Nullify', unlocked: true).present? && @opponent.nullify == false)
                nullify_image = "<img src='/assets/mage_skills/nullify.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat = 1
                @opponent.nullify = true
                log_message = "#{@opponent.character_name} has triggered #{nullify_image} Nullify" if @opponent.nullify == true
                @combat_logs << log_message
            end
            # Ephemeral Rebirth - Initialize
            if (@opponent_health_in_combat <= 0 && @opponent.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @opponent.ephemeral_rebirth  == false)
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @opponent_health_in_combat = @opponent.total_max_health
                @opponent.ephemeral_rebirth = true
                log_message = "#{@opponent.character_name} has triggered#{ephemeral_rebirth_image} Ephemeral Rebirth" if @opponent.ephemeral_rebirth == true
                @combat_logs << log_message
            end
        elsif @opponent_turn
            # Death's Bargain
            if ((@character.total_health <= 0 && @character.off_hand.present? && @character.off_hand.name  == "Death's Bargain") && @character.deathsbargain  == false)
                deathsbargain_image = "<img src='/assets/legendary_items/deathsbargain.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health = 1
                @character.deathsbargain = true
                log_message = "#{@character.character_name} has triggered #{deathsbargain_image} Death's Bargain" if @character.deathsbargain == true
                @combat_logs << log_message
            end
            # Nullify
            if (@character.total_health <= 0 && @character.skills.find_by(name: 'Nullify', unlocked: true).present? && @character.nullify == false)
                nullify_image = "<img src='/assets/mage_skills/nullify.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health = 1
                @character.nullify = true
                log_message = "#{@character.character_name} has triggered #{nullify_image} Nullify" if @character.nullify == true
                @combat_logs << log_message
            end
            # Ephemeral Rebirth - Initialize
            if (@character.total_health <= 0 && @character.skills.find_by(name: 'Ephemeral Rebirth', unlocked: true).present? && @character.ephemeral_rebirth  == false)
                ephemeral_rebirth_image = "<img src='/assets/deathwalker_skills/ephemeralrebirth.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
                @character.total_health = @character.total_max_health
                @character.ephemeral_rebirth = true
                log_message = "#{@character.character_name} has triggered #{ephemeral_rebirth_image} Ephemeral Rebirth" if @character.ephemeral_rebirth == true
                @combat_logs << log_message
            end
        end
    end

    def log_health_values
        character_health_status = @character.total_health > 0 ? "#{@character.total_health} / #{@character.total_max_health}" : "☠ #{@character.total_health} / #{@character.total_max_health}"
        opponent_health_status = @opponent_health_in_combat > 0 ? "#{@opponent_health_in_combat} / #{@opponent.total_max_health}" : "☠ #{@opponent_health_in_combat} / #{@opponent.total_max_health}"

        log_message = "#{@character.character_name}: <span style=\"text-decoration: underline;\"><strong>#{character_health_status}</strong></span>  |  #{@opponent.character_name}: <span style=\"text-decoration: underline;\"><strong>#{opponent_health_status}</strong></span>"
        @combat_logs << log_message
    end

    def character_turn
        # Reset character combat variables
        @character_has_missed = false
        @opponent_has_evaded = false
        @character_has_crit = false
        @opponent_has_ignored_pain = false
        @opponent_has_blocked = false
        # Turn based counts
        @character_blessing_of_kings_turn -= 1 unless @character_blessing_of_kings_turn == 0
        # Blessing of kings - Paladin talent
        if @character.skills.find_by(name: 'Blessing of Kings', unlocked: true).present? && (@character_blessing_of_kings_turn == 0 && @character.blessing_of_kings == false)
            @character.blessing_of_kings = true
            @character_blessing_of_kings_turn = 4
            blessing_of_kings_buff = 0.15
            @character.buffed_damage_reduction += blessing_of_kings_buff
            blessing_of_kings_image = "<img src='/assets/paladin_skills/blessingofkings.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            log_message = "#{@character.character_name}: #{blessing_of_kings_image} Blessing of Kings triggered"
            @combat_logs << log_message
            if @character.skills.find_by(name: 'Blessing of Kings', unlocked: true).present? && (@character_blessing_of_kings_turn == 0 && @character.blessing_of_kings == true)
                @character.buffed_damage_reduction -= blessing_of_kings_buff
            end
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
        turn_loop = [
            method(:basic_attack),
            method(:extra_attack_talent),
            method(:extra_attack_item),
            method(:damage_talent),
            method(:damage_item),
            method(:damage_end_of_turn_talent),
            method(:execute_item)
        ]
        turn_loop.each do |method|
            break if @opponent_health_in_combat <= 0
            method.call
        end
        @opponent_health_in_combat = [@opponent_health_in_combat, 0].max
        log_health_values
        cheat_death if @opponent_health_in_combat <= 0
        # Reset took damage to false
        @character.took_damage = false
    end

    def opponent_turn
        # Reset opponent combat variables
        @opponent_has_missed = false
        @character_has_evaded = false
        @opponent_has_crit = false
        @character_has_ignored_pain = false
        @character_has_blocked = false
        # Turn based counts
        @opponent_blessing_of_kings_turn -= 1 unless @opponent_blessing_of_kings_turn == 0
        # Blessing of kings - Paladin talent
        if @opponent.is_a?(Character) && (@character.skills.find_by(name: 'Blessing of Kings', unlocked: true).present? && (@opponent_blessing_of_kings_turn == 0 && @opponent.blessing_of_kings == false))
            @opponent.blessing_of_kings = true
            @opponent_blessing_of_kings_turn = 4
            blessing_of_kings_buff = 0.15
            @opponent.buffed_damage_reduction += blessing_of_kings_buff
            blessing_of_kings_image = "<img src='/assets/paladin_skills/blessingofkings.jpg' style='width: 25px; height: 25px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;' alt='Swift Movements' class='log-skill-image'>"
            log_message = "#{@opponent.character_name}: #{blessing_of_kings_image} Blessing of Kings triggered"
            @combat_logs << log_message
            if @opponent.skills.find_by(name: 'Blessing of Kings', unlocked: true).present? && (@opponent_blessing_of_kings_turn == 0 && @opponent.blessing_of_kings == true)
                @opponent.buffed_damage_reduction -= blessing_of_kings_buff
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
        turn_loop = [
            method(:basic_attack),
            method(:extra_attack_talent),
            method(:extra_attack_item),
            method(:damage_talent),
            method(:damage_item),
            method(:damage_end_of_turn_talent),
            method(:execute_item)
        ]
        turn_loop.each do |method|
            break if @character.total_health <= 0
            method.call
        end
        @character.total_health = [@character.total_health, 0].max
        log_health_values
        cheat_death if @character.total_health <= 0
        # Reset damage taken flag
        @opponent.took_damage = false
    end
end
