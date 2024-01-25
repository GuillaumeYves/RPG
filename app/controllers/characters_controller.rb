class CharactersController < ApplicationController
before_action :authenticate_user!, only: [:new, :create, :user_characters]

    def new
        @character = current_user.characters.build
    end

    def leaderboard
        @characters = Character.order(level: :desc).limit(20)
    end

    def create
        @character = current_user.characters.build(character_params)

        @character.set_race_image

        @character.set_default_values_for_buffed_stats

        @character.modify_stats_based_on_race
        @character.set_default_values_for_total_stats
        @character.modify_attributes_based_on_class
        @character.modify_stats_based_on_attributes

        if @character.save
            @character.create_inventory
            @character.assign_skills_based_on_class
        
        flash[:notice] = 'Character created.'
        redirect_to user_characters_path

        else
        flash[:alert] = 'An error occured. Please try again.'
        redirect_to new_character_path
        end

    end

    def user_characters
        @characters = current_user.characters
    end

    def select
        @selected_character = Character.find(params[:id])

        if current_user.selected_character.present?
            current_user.selected_character.update(user: nil) # Clear the association if it was present
        end 

        session[:selected_character_id] = @selected_character.id
        current_user.update(selected_character: @selected_character)

        redirect_to character_path(@selected_character), notice: "You selected #{@selected_character.character_name}."
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
        @items = Item.all
        @hunts = Hunt.all
        @skills = @character.skills
    end

    def gain_experience
        @selected_character = Character.find(params[:id])
        amount = params[:amount].to_i

        # Scale the experience to increase difficulty based on level
        scaling_factor = case @selected_character.level
        # 5% reduction per case up to level 500 and beyond where its 80% reduction 
            when 10..19 then 0.95
            when 20..29 then 0.90
            when 30..39 then 0.85 
            when 40..49 then 0.80
            when 50..59 then 0.75
            when 60..79 then 0.70
            when 80..99 then 0.65 
            when 100..149 then 0.60 
            when 150..199 then 0.55  
            when 200..249 then 0.50
            when 250..299 then 0.45
            when 300..349 then 0.40
            when 350..399 then 0.35
            when 400..449 then 0.30
            when 450..499 then 0.25
            when 500..Float::INFINITY then 0.20
            else 1.0
        end
        @selected_character.increment(:experience, (amount * (1.1 ** (@selected_character.level - 1)) * scaling_factor).round)           
        
    # Check if the character can level up
    while @selected_character.experience >= @selected_character.required_experience_for_next_level
            @selected_character.level_up
            flash[:notice] = "You are now level #{@selected_character.level}."
    end

        @selected_character.save
    
    redirect_to @selected_character
    end

    def complete_hunt
        @selected_character = current_user.selected_character
        @hunt = Hunt.find(params[:hunt_id])
        amount = params[:experience_reward].to_i
        
        # Scale the experience to increase difficulty based on level
        scaling_factor = case @selected_character.level
        # 5% reduction per case up to level 500 and beyond where its 80% reduction 
            when 10..19 then 0.95
            when 20..29 then 0.90
            when 30..39 then 0.85 
            when 40..49 then 0.80
            when 50..59 then 0.75
            when 60..79 then 0.70
            when 80..99 then 0.65 
            when 100..149 then 0.60 
            when 150..199 then 0.55  
            when 200..249 then 0.50
            when 250..299 then 0.45
            when 300..349 then 0.40
            when 350..399 then 0.35
            when 400..449 then 0.30
            when 450..499 then 0.25
            when 500..Float::INFINITY then 0.20
            else 1.0
        end

        @selected_character.increment(:experience, (amount * (1.1 ** (@selected_character.level - 1)) * scaling_factor).round)           
        
        # Check if the character can level up
        while @selected_character.experience >= @selected_character.required_experience_for_next_level
            @selected_character.level_up
            flash[:notice] = "You are now level #{@selected_character.level}."
        end

        # Drop the completed hunt
        @selected_character.update(accepted_hunt: nil)

        # Save character
        @selected_character.save

        redirect_to @selected_character
        flash[:notice] = 'Hunt completed.'
    end

    def equip_item
        @selected_character = current_user.selected_character
        item = Item.find(params[:item_id])

        case item.item_type
            when "One-handed Weapon"
                @selected_character.equip_one_handed_weapon(item)
            when "Two-handed Weapon"
                @selected_character.equip_two_handed_weapon(item)
            when "Shield"
                @selected_character.equip_shield(item)
            when "Helmet"
                @selected_character.equip_helmet(item)
            when "Chest"
                @selected_character.equip_chest(item)
            when "Legs"
                @selected_character.equip_legs(item)
            when "Amulet"
                @selected_character.equip_amulet(item)
            when "Ring"
                @selected_character.equip_ring(item)
            when "Waist"
                @selected_character.equip_waist(item)
            when "Gloves"
                @selected_character.equip_hands(item)
            when "Boots"
                @selected_character.equip_feet(item)
            # Add mappings for other item types
        else
        end
        
        @selected_character.modify_stats_based_on_attributes
        @selected_character.apply_passive_skills
        # Redirect to the show character page
        redirect_to @selected_character, notice: "#{item.name} equipped."
    end


    def unequip_item
        @selected_character = current_user.selected_character
        item = Item.find(params[:item_id])

        case item.item_type
        when "One-handed Weapon"
            @selected_character.unequip_one_handed_weapon(@selected_character.main_hand_item)
        when "Two-handed Weapon"
            @selected_character.unequip_two_handed_weapon(@selected_character.main_hand_item)
        when "Shield"
            @selected_character.unequip_shield(@selected_character.off_hand_item)
        when "Helmet"
            @selected_character.unequip_helmet(@selected_character.helmet_item)
        when "Chest"
            @selected_character.unequip_chest(@selected_character.chest_item)
        when "Legs"
            @selected_character.unequip_legs(@selected_character.legs_item)
        when "Amulet"
            @selected_character.unequip_amulet(@selected_character.neck_item)
        when "Ring"
            @selected_character.unequip_ring(@selected_character.finger1_item)
        when "Waist"
            @selected_character.unequip_waist(@selected_character.waist_item)
        when "Gloves"
            @selected_character.unequip_hands(@selected_character.hands_item)
        when "Boots"
            @selected_character.unequip_feet(@selected_character.feet_item)
        # Add mappings for other item types
        else
        Rails.logger.warn("Unsupported item type: #{item.item_type}")
        end

        @selected_character.modify_stats_based_on_attributes
        @selected_character.apply_passive_skills
        @selected_character.save
        # Redirect to the show character page
        redirect_to @selected_character, notice: "#{item.name} unequipped."
    end

    def add_to_inventory
    @selected_character = Character.find(session[:selected_character_id])
    inventory = @selected_character.inventory
    item = Item.find(params[:item_id])

        if inventory.items.count < 10
        flash[:notice] = "#{item.name} added to inventory."
        inventory.items << item
        inventory.save
        redirect_back fallback_location: root_path
        else
            flash[:alert] = 'Inventory is full.'
            redirect_back fallback_location: root_path
        end
    end

    def unlock_skill
        @character = current_user.selected_character
        skill_id = params[:skill_id]
        skill = Skill.find(skill_id)

        if @character.level < skill.level_requirement || !skill.locked
            flash[:alert] = 'You do not meet the level requirement to unlock this talent.'
        elsif @character.skills.where(row: skill.row, unlocked: true).exists?
            flash[:alert] = 'You can only unlock one talent from this row.'
        elsif @character.skill_points.zero?
            flash[:alert] = 'You have no talent point.'
        else
            skill.update(unlocked: true, locked: false)
            @character.apply_passive_skills
            @character.modify_stats_based_on_attributes
            @character.decrement(:skill_points)
            @character.save
            flash[:notice] = 'Talent unlocked.'
            puts "Intermediate values - Armor: #{@character.armor}, Magic Resistance: #{@character.magic_resistance}, Spellpower: #{@character.spellpower}, Updated Attack: #{@character.attack}"
        end

        redirect_to @character
    end

    private

    def character_params
        params.require(:character).permit(:race, :race_image, :character_class, :gender, :character_name, :max_health, :health, :attack, :armor, :spellpower, :magic_resistance, :strength, :intelligence, :luck, :willpower)
    end
end
