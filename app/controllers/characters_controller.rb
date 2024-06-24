class CharactersController < ApplicationController
before_action :authenticate_user!, only: [:new, :create, :user_characters]

    def new
        @character = current_user.characters.build
    end

    def leaderboard
        @characters = Character.order(level: :desc)
    end

    def thaumaturge
        @character = current_user.selected_character
        @healing_potions = Item.where(item_type: "Healing Potion")
        @elixirs = Item.where(item_type: "Elixir")
    end

    def heal
        @character = current_user.selected_character
        healing_cost = 10

        if @character.total_health < @character.total_max_health
            if @character.gold >= healing_cost
                @character.total_health = @character.total_max_health
                @character.gold -= healing_cost
                @character.save
                flash[:notice] = "You feel refreshed."
            else
                flash[:alert] = "You do not have enough gold."
            end
        else
            flash[:alert] = "Your health is already full."
        end

        respond_to do |format|
        format.js { render js: "window.location.reload()" }
        end
    end

    def create
        @character = current_user.characters.build(character_params)

        @character.set_race_image

        @character.set_default_values_for_buffed_stats

        @character.modify_stats_based_on_race
        @character.modify_attributes_based_on_class
        @character.set_default_values_for_total_stats
        @character.modify_stats_based_on_attributes

        if @character.save
            @character.create_inventory
            @character.assign_skills_based_on_class

        flash[:notice] = 'Character created.'
        redirect_to user_characters_path

        if current_user.characters.count == 1
            flash[:tutorial] = true
        end

        else

            character_name_errors = @character.errors[:character_name]
            if character_name_errors.present?
                flash[:alert] = "Character name #{character_name_errors.join(' and ')}"
            else
                flash[:alert] = 'An error occured. Please try again.'
            end
            redirect_to new_character_path
        end
    end

    def select
        @selected_character = Character.find(params[:id])

        if current_user.selected_character.present?
            current_user.selected_character.update(user: nil)
        end

        session[:selected_character_id] = @selected_character.id
        current_user.update(selected_character: @selected_character)

        redirect_to character_path(@selected_character)
    end

    def user_characters
        @characters = current_user.characters
        if current_user.selected_character.present?
            current_user.selected_character.update(user: nil)
            session[:selected_character_id] = nil
            current_user.update(selected_character: nil)
        end
    end

    def arena
        user_characters = current_user.characters
        user_character = current_user.selected_character
        min_rank = [user_character.arena_rank - 10, 0].max
        max_rank = user_character.arena_rank + 10
        @opponents = Character.where('"arena_rank" >= ? AND "arena_rank" <= ?', min_rank, max_rank)
                                .where.not(id: user_characters.pluck(:id))
                                .where('total_health = total_max_health')
                                .limit(3)
        @combat_results = CombatResult.where(opponent_type: 'Character', opponent_id: current_user.selected_character.id).order(created_at: :desc).limit(10)
    end

    def destroy
        @character = Character.find(params[:id])
        @character.update(accepted_hunt: nil)
        User.where(selected_character_id: @character.id).update_all(selected_character_id: nil)

        @character.destroy

        redirect_to user_characters_path
        flash[:notice]= 'Character was deleted.'
    end

    def show
        @character = Character.find(params[:id])
        @selected_character = current_user.selected_character if current_user.selected_character.present?
        @items = Item.all
        @hunts = Hunt.all
        @skills = @character.skills
    end

    def talents
        @character = current_user.selected_character
        @skills = @character.skills
    end

    def paragon_increase_attack
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_attack_count < 50
                if @character.paragon_points > 0
                    @character.paragon_attack += 0.01
                    @character.modify_stats_based_on_attributes
                    @character.apply_passive_skills
                    @character.update_elixir_effect
                    @character.decrement(:paragon_points)
                    @character.increment(:paragon_increase_attack_count)
                    @character.save
                else
                    flash[:alert] = "Not enough paragon points."
                end
            else
                flash[:alert] = "You increased this Paragon power to its maximum."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
        format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_increase_armor
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_armor_count < 50
                if @character.paragon_points > 0
                    @character.paragon_armor += 0.005
                    @character.modify_stats_based_on_attributes
                    @character.apply_passive_skills
                    @character.update_elixir_effect
                    @character.decrement(:paragon_points)
                    @character.increment(:paragon_increase_armor_count)
                    @character.save
                else
                    flash[:alert] = "Not enough paragon points."
                end
            else
                flash[:alert] = "You increased this Paragon power to its maximum."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
        format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_increase_spellpower
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_spellpower_count < 50
                if @character.paragon_points > 0
                    @character.paragon_spellpower += 0.01
                    @character.modify_stats_based_on_attributes
                    @character.apply_passive_skills
                    @character.update_elixir_effect
                    @character.decrement(:paragon_points)
                    @character.increment(:paragon_increase_spellpower_count)
                    @character.save
                else
                    flash[:alert] = "Not enough paragon points."
                end
            else
                flash[:alert] = "You increased this Paragon power to its maximum."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
        format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_increase_magic_resistance
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_magic_resistance_count < 50
                if @character.paragon_points > 0
                    @character.paragon_magic_resistance += 0.005
                    @character.modify_stats_based_on_attributes
                    @character.apply_passive_skills
                    @character.update_elixir_effect
                    @character.decrement(:paragon_points)
                    @character.increment(:paragon_increase_magic_resistance_count)
                    @character.save
                else
                    flash[:alert] = "Not enough paragon points."
                end
            else
                flash[:alert] = "You increased this Paragon power to its maximum."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
        format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_increase_critical_strike_chance
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_critical_strike_chance_count < 50
                if @character.paragon_points > 0
                    @character.paragon_critical_strike_chance += 0.10
                    @character.modify_stats_based_on_attributes
                    @character.apply_passive_skills
                    @character.update_elixir_effect
                    @character.decrement(:paragon_points)
                    @character.increment(:paragon_increase_critical_strike_chance_count)
                    @character.save
                else
                    flash[:alert] = "Not enough paragon points."
                end
            else
                flash[:alert] = "You increased this Paragon power to its maximum."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_increase_critical_strike_damage
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_critical_strike_damage_count < 50
                if @character.paragon_points > 0
                    @character.paragon_critical_strike_damage += 0.01
                    @character.modify_stats_based_on_attributes
                    @character.apply_passive_skills
                    @character.update_elixir_effect
                    @character.decrement(:paragon_points)
                    @character.increment(:paragon_increase_critical_strike_damage_count)
                    @character.save
                else
                    flash[:alert] = "Not enough paragon points."
                end
            else
                flash[:alert] = "You increased this Paragon power to its maximum."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_increase_total_health
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_total_health_count < 50
                if @character.paragon_points > 0
                    @character.paragon_total_health += 0.004
                    @character.modify_stats_based_on_attributes
                    @character.apply_passive_skills
                    @character.update_elixir_effect
                    @character.decrement(:paragon_points)
                    @character.increment(:paragon_increase_total_health_count)
                    @character.save
                else
                    flash[:alert] = "Not enough paragon points."
                end
            else
                flash[:alert] = "You increased this Paragon power to its maximum."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_increase_global_damage
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_global_damage_count < 50
                if @character.paragon_points > 0
                    @character.paragon_global_damage += 0.004
                    @character.modify_stats_based_on_attributes
                    @character.apply_passive_skills
                    @character.update_elixir_effect
                    @character.decrement(:paragon_points)
                    @character.increment(:paragon_increase_global_damage_count)
                    @character.save
                else
                    flash[:alert] = "Not enough paragon points."
                end
            else
                flash[:alert] = "You increased this Paragon power to its maximum."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_reset_attack
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_attack_count > 0
                @character.paragon_points += @character.paragon_increase_attack_count
                @character.paragon_attack = 0.00
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                @character.update_elixir_effect
                @character.paragon_increase_attack_count = 0
                @character.save
                flash[:notice] = "Paragon power successfully reset."
            else
                flash[:alert] = "You have not spent Paragon points on this power."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_reset_armor
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_armor_count > 0
                @character.paragon_points += @character.paragon_increase_armor_count
                @character.paragon_armor = 0.00
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                @character.update_elixir_effect
                @character.paragon_increase_armor_count = 0
                @character.save
                flash[:notice] = "Paragon power successfully reset."
            else
                flash[:alert] = "You have not spent Paragon points on this power."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_reset_spellpower
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_spellpower_count > 0
                @character.paragon_points += @character.paragon_increase_spellpower_count
                @character.paragon_spellpower = 0.00
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                @character.update_elixir_effect
                @character.paragon_increase_spellpower_count = 0
                @character.save
                flash[:notice] = "Paragon power successfully reset."
            else
                flash[:alert] = "You have not spent Paragon points on this power."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_reset_magic_resistance
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_magic_resistance_count > 0
                @character.paragon_points += @character.paragon_increase_magic_resistance_count
                @character.paragon_magic_resistance = 0.00
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                @character.update_elixir_effect
                @character.paragon_increase_magic_resistance_count = 0
                @character.save
                flash[:notice] = "Paragon power successfully reset."
            else
                flash[:alert] = "You have not spent Paragon points on this power."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_reset_critical_strike_chance
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_critical_strike_chance_count > 0
                @character.paragon_points += @character.paragon_increase_critical_strike_chance_count
                @character.paragon_critical_strike_chance = 0.00
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                @character.update_elixir_effect
                @character.paragon_increase_critical_strike_chance_count = 0
                @character.save
                flash[:notice] = "Paragon power successfully reset."
            else
                flash[:alert] = "You have not spent Paragon points on this power."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_reset_critical_strike_damage
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_critical_strike_damage_count > 0
                @character.paragon_points += @character.paragon_increase_critical_strike_damage_count
                @character.paragon_critical_strike_damage = 0.00
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                @character.update_elixir_effect
                @character.paragon_increase_critical_strike_damage_count = 0
                @character.save
                flash[:notice] = "Paragon power successfully reset."
            else
                flash[:alert] = "You have not spent Paragon points on this power."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_reset_total_health
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_armor_count > 0
                @character.paragon_points += @character.paragon_increase_total_health_count
                @character.paragon_total_health = 0.00
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                @character.update_elixir_effect
                @character.paragon_increase_total_health_count = 0
                @character.save
                flash[:notice] = "Paragon power successfully reset."
            else
                flash[:alert] = "You have not spent Paragon points on this power."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def paragon_reset_global_damage
        @character = current_user.selected_character
        if @character.level >= 100
            if @character.paragon_increase_global_damage_count > 0
                @character.paragon_points += @character.paragon_increase_global_damage_count
                @character.paragon_global_damage = 0.00
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                @character.update_elixir_effect
                @character.paragon_increase_global_damage_count = 0
                @character.save
                flash[:notice] = "Paragon power successfully reset."
            else
                flash[:alert] = "You have not spent Paragon points on this power."
            end
        else
            flash[:alert] = "You must be at least level 100 to unlock Paragon powers."
        end
        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    def gain_experience
        @character = current_user.selected_character

        scaling_factor = case @character.level
            when 1..9 then 1.0
            when 10..19 then 0.90
            when 20..39 then 0.80
            when 40..49 then 0.70
            when 50..59 then 0.60
            when 60..69 then 0.50
            when 70..79 then 0.40
            when 80..99 then 0.30
            when 100..199 then 0.20
            when 200..299 then 0.10
            when 300..Float::INFINITY then 0.05
            else 1.0
        end

        amount = ((params[:amount].to_i * @character.level) * scaling_factor).round
        gold_reward = (params[:gold_reward].to_i)

        @character.increment(:experience, amount)
        @character.increment(:gold, gold_reward)

        flash[:notice] = "You gained #{amount} EXP and #{gold_reward} gold"
        puts "######################### #{@character.gold}"
        # Check if the character can level up
        while @character.experience >= @character.required_experience_for_next_level
            @character.level_up
            flash[:notice] = "You are now level #{@character.level}."
        end
        @character.save
        redirect_to @character
    end

    def complete_hunt
        @character = current_user.selected_character
        @hunt = @character.accepted_hunt
        gold_reward = @hunt.gold_reward
        # Use the scaled_experience_reward method from the Hunt model
        amount = @hunt.scaled_experience_reward(@character.level)
        # Add EXP and Gold to character
        @character.increment(:experience, amount)
        @character.increment(:gold, gold_reward)
        # Check if the character can level up
        while @character.experience >= @character.required_experience_for_next_level
            @character.level_up
            flash[:notice] = "You are now level #{@character.level}."
        end
        # Drop the completed hunt
        @character.update(accepted_hunt: nil)
        # Drop the combat result from the hunt if combat occured
        @hunt.update(combat_result: nil)
        @character.save

        flash[:notice] = "Hunt completed. You gained #{amount} experience and #{gold_reward} gold"
        redirect_to @character
    end

    def equip_item
        @character = current_user.selected_character
        item = Item.find(params[:item_id])
        if @character.can_equip?(item)
            case item.item_type
                when "One-handed Weapon"
                    @character.equip_one_handed_weapon(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Two-handed Weapon"
                    @character.equip_two_handed_weapon(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Shield"
                    @character.equip_shield(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Head"
                    @character.equip_head(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Chest"
                    @character.equip_chest(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Neck"
                    @character.equip_neck(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Finger"
                    @character.equip_ring(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Waist"
                    @character.equip_waist(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Hands"
                    @character.equip_hands(item)
                    flash[:notice] = "#{item.name} equipped."
                when "Feet"
                    @character.equip_feet(item)
                    flash[:notice] = "#{item.name} equipped."
            end
            @character.modify_stats_based_on_attributes
            @character.apply_passive_skills
            @character.update_elixir_effect
            @character.save
            redirect_to @character
        else
            flash[:alert] = @character.errors.full_messages.join(',')
            redirect_to @character
        end
    end

    def unequip_item
        @character = current_user.selected_character
        item = Item.find(params[:item_id])

        if @character.main_hand == item
            @character.unequip_main_hand
        elsif @character.off_hand == item
            @character.unequip_off_hand
        elsif @character.head == item
            @character.unequip_head
        elsif @character.chest == item
            @character.unequip_chest
        elsif @character.neck == item
            @character.unequip_neck
        elsif @character.finger1 == item
            @character.unequip_finger1
        elsif @character.finger2 == item
            @character.unequip_finger2
        elsif @character.waist == item
            @character.unequip_waist
        elsif @character.hands == item
            @character.unequip_hands
        elsif @character.feet == item
            @character.unequip_feet
        else
            flash[:error] = "Item not equipped in any slot"
            redirect_to @character and return
        end

        @character.modify_stats_based_on_attributes
        @character.apply_passive_skills
        @character.update_elixir_effect
        @character.save

        redirect_to @character, notice: "#{item.name} unequipped."
    end

    def add_to_inventory
        @character = current_user.selected_character
        inventory = @character.inventory
        item = Item.find(params[:item_id])

        if @character.gold >= item.gold_price
            if inventory.items.count < 10
                @character.gold -= item.gold_price
                flash[:notice] = "#{item.name} bought for #{item.gold_price} gold."
                inventory.items << item
                inventory.save
                @character.save
                item.update(merchant_item: false)
                respond_to do |format|
                    format.js { render js: "window.location.reload()" }
                end
            else
                flash[:alert] = 'Inventory is full.'
                respond_to do |format|
                    format.js { render js: "window.location.reload()" }
                end
            end
        else
            flash[:alert] = 'You do not have enough gold for this item.'
            respond_to do |format|
                format.js { render js: "window.location.reload()" }
            end
        end
    end

    def sell_item
        @character = current_user.selected_character
        inventory = @character.inventory
        item = Item.find(params[:item_id])

        if inventory.items.include?(item)
            selling_price = (item.gold_price * 0.65).round
            @character.gold += selling_price
            flash[:notice] = "#{item.name} sold for #{selling_price} gold."
            inventory.items.delete(item)
            inventory.save
            @character.save
            respond_to do |format|
                format.js { render js: "window.location.reload()" }
            end
        else
            flash[:alert] = 'Item not found in inventory.'
            respond_to do |format|
                format.js { render js: "window.location.reload()" }
            end
        end
    end

    def learn_skill
        @character = current_user.selected_character
        skill_id = params[:skill_id]
        skill = Skill.find(skill_id)

        if @character.level < skill.level_requirement
            flash[:alert] = 'You do not meet the level requirement to learn this talent.'
        elsif @character.skills.where(row: skill.row, unlocked: true).exists?
            flash[:alert] = 'You can only learn one talent from this row.'
        elsif @character.skill_points.zero?
            flash[:alert] = 'You have no talent point.'
        else
            skill.update(unlocked: true, locked: false)
            @character.apply_passive_skills
            @character.modify_stats_based_on_attributes
            @character.update_elixir_effect
            @character.decrement(:skill_points)
            @character.save
            flash[:notice] = 'Talent learned.'
        end

        redirect_to talents_character_path
    end

    def unlearn_skill
        @character = current_user.selected_character
        skill_id = params[:skill_id]
        skill = Skill.find(skill_id)

        if !skill.unlocked
            flash[:alert] = 'You have not learned this skill.'
        elsif skill.unlocked
            skill.update(unlocked: false, locked: true)
            @character.apply_passive_skills
            @character.modify_stats_based_on_attributes
            @character.update_elixir_effect
            @character.increment(:skill_points)
            @character.save
            flash[:notice] = 'Talent unlearned.'
        end

        redirect_to talents_character_path
    end

    def use_elixir
        @character = Character.find(session[:selected_character_id])
        inventory = @character.inventory
        item = Item.find(params[:item_id])

        if item.item_type == "Elixir" && @character.active_elixir_ids.length < 3
            if @character.active_elixir_ids.any? { |elixir_id| Item.find(elixir_id).name == item.name }
                flash[:alert] = "You already have an active #{item.name}."
            else
                case item.name
                when "Elixir of Might"
                    @character.update(elixir_attack: (@character.total_attack * item.potion_effect))
                when "Elixir of Power"
                    @character.update(elixir_spellpower: (@character.total_spellpower * item.potion_effect))
                when "Elixir of Decay"
                    @character.update(elixir_necrosurge: (@character.total_necrosurge * item.potion_effect))
                when "Elixir of Fortitude"
                    @character.update(elixir_armor: (@character.total_armor * item.potion_effect))
                when "Elixir of Knowledge"
                    @character.update(elixir_magic_resistance: (@character.total_magic_resistance * item.potion_effect))
                end

                item.update(elixir_applied_at: Time.current)
                @character.active_elixir_ids << item.id
                @character.elixir_active = true
                @character.modify_stats_based_on_attributes
                @character.apply_passive_skills
                inventory.items.delete(item)
                inventory.save
                @character.save
            end
        else
            flash[:alert] = 'You already have 3 elixirs active.'
        end

        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

    private

    def character_params
        params.require(:character).permit(:race, :race_image, :character_class, :gender, :character_name, :max_health, :health, :attack, :armor, :spellpower, :necrosurge, :magic_resistance, :strength, :intelligence, :agility, :dreadmight, :luck, :willpower)
    end
end
