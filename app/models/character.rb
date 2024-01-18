class Character < ApplicationRecord
belongs_to :user

belongs_to :hunt, optional: true, dependent: :destroy
has_one :accepted_hunt, class_name: 'Hunt', foreign_key: 'character_id'

has_one :inventory, dependent: :destroy
has_many :items, dependent: :destroy

has_many :skills, dependent: :destroy
has_many :selected_skills, class_name: "Skill", foreign_key: "character_id", dependent: :destroy

belongs_to :main_hand_item, class_name: 'Item', foreign_key: 'main_hand', optional: true
belongs_to :off_hand_item, class_name: 'Item', foreign_key: 'off_hand', optional: true
belongs_to :head_item, class_name: 'Item', foreign_key: 'head', optional: true
belongs_to :chest_item, class_name: 'Item', foreign_key: 'chest', optional: true
belongs_to :legs_item, class_name: 'Item', foreign_key: 'legs', optional: true
belongs_to :neck_item, class_name: 'Item', foreign_key: 'neck', optional: true
belongs_to :finger1_item, class_name: 'Item', foreign_key: 'finger1', optional: true
belongs_to :finger2_item, class_name: 'Item', foreign_key: 'finger2', optional: true
belongs_to :waist_item, class_name: 'Item', foreign_key: 'waist', optional: true
belongs_to :hands_item, class_name: 'Item', foreign_key: 'hands', optional: true
belongs_to :feet_item, class_name: 'Item', foreign_key: 'feet', optional: true

has_one_attached :race_image

validates :character_class, presence: true
validates :race, presence: true
validates :gender, presence: true
validates :character_name, presence: true
validates :level, presence: true, numericality: { only_integer: true, greater_than: 0 }
validates :experience, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
validates :skill_points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

validate :max_characters, on: :create

    def create_inventory
        Inventory.create(character: self)
    end

    def set_race_image
        case race
        when 'human'
            image_path = case gender
                        when 'female'
                        'female_human.jpg'
                        else
                        'human.jpg'
                        end
        when 'elf'
            image_path = case gender
                        when 'female'
                        'female_elf.jpg'
                        else
                        'elf.jpg'
                        end
        when 'dwarf'
            image_path = case gender
                        when 'female'
                        'female_dwarf.jpg'
                        else
                        'dwarf.jpg'
                        end
        when 'orc'
            image_path = case gender
                        when 'female'
                        'female_orc.jpg'
                        else
                        'orc.jpg'
                        end
        end
        # Check if image is already attached before attaching
        unless race_image.attached?
            self.race_image.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'races', image_path)), filename: File.basename(image_path), content_type: 'image/jpeg')
        end
    end

    # Add methods to modify stats based on race
    def modify_stats_based_on_race
        case race
        when 'human'
            # Human race will keep base stats
        when 'elf'
            # Modify stats for elf race
            self.health -= 20
            self.attack -= 3
            self.armor -= 2
            self.spellpower += 3
            self.magic_resistance += 2
        when 'dwarf'
            # Modify stats for dwarf race
            self.health -= 10
            self.attack += 1
            self.armor += 2
            self.spellpower -= 1
            self.magic_resistance += 2
        when 'orc'
            # Modify stats for orc race
            self.health += 20
            self.attack += 5
            self.armor -= 3
            self.spellpower -= 3
            self.magic_resistance -= 3
        end
    end

    # Add methods to modify attributes based on class
    def modify_attributes_based_on_class
        case character_class
        when 'warrior'
            # Modify attributes for warrior class
            self.strength += 2
            self.intelligence -= 3
            self.agility -= 3
            self.luck += 1
            self.willpower += 1
        when 'mage'
            # Modify attributes for mage class
            self.strength -= 3
            self.intelligence += 3
            self.agility -= 3
            self.luck += 2
            self.willpower -= 3
        when 'rogue'
            # Modify attributes for rogue class
            self.strength += 1
            self.intelligence -= 2
            self.agility += 2
            self.luck += 2
            self.willpower -= 3
        when 'paladin'
            # Modify attributes for paladin class
            self.strength += 1
            self.intelligence += 1
            self.agility -= 3
            self.luck += 1
            self.willpower += 1
        end
    end
    
    def modify_stats_based_on_attributes
        self.attack += strength_bonus
        self.spellpower += intelligence_bonus
        critical_strike_chance
        evasion
        ignore_pain_chance
    end

    def strength_bonus
        self.strength * 0.04
    end

    def intelligence_bonus
        self.intelligence * 0.04
    end

    def critical_strike_chance
        self.luck * 0.05
    end

    def evasion
        self.agility * 0.03
    end

    def ignore_pain_chance
        self.willpower * 0.03
    end

    def assign_skills_based_on_class
        case character_class
            when 'warrior'
                # Seed warrior skills
                warrior_skills_seeder = WarriorSkillsSeeder.new(self)
                warrior_skills_seeder.seed_skills
            when 'mage'
                # Seed mage skills
                mage_skills_seeder = MageSkillsSeeder.new(self)
                mage_skills_seeder.seed_skills
            when 'rogue'
                # Seed rogue skills
                rogue_skills_seeder = RogueSkillsSeeder.new(self)
                rogue_skills_seeder.seed_skills
            when 'paladin'
                # Seed paladin skills
                paladin_skills_seeder = PaladinSkillsSeeder.new(self)
                paladin_skills_seeder.seed_skills    
            end
    end

    def revert_stats_based_on_item(item)
        # Subtract stats of the unequipped item
        self.attack -= item.attack unless item.attack.nil?
        self.health -= item.health unless item.health.nil?
        self.armor -= item.armor unless item.armor.nil?
        self.spellpower -= item.spellpower unless item.spellpower.nil?
        self.magic_resistance -= item.magic_resistance unless item.magic_resistance.nil?
        self.strength -= item.strength unless item.strength.nil?
        self.intelligence -= item.intelligence unless item.intelligence.nil?
        self.luck -= item.luck unless item.luck.nil?
        self.willpower -= item.willpower unless item.willpower.nil?
    end

    def modify_stats_based_on_item(item)
        # Adds stats of the equipped item
        self.attack += item.attack unless item.attack.nil?
        self.health += item.health unless item.health.nil?
        self.armor += item.armor unless item.armor.nil?
        self.spellpower += item.spellpower unless item.spellpower.nil?
        self.magic_resistance += item.magic_resistance unless item.magic_resistance.nil?
        self.strength += item.strength unless item.strength.nil?
        self.intelligence += item.intelligence unless item.intelligence.nil?
        self.luck += item.luck unless item.luck.nil?
        self.willpower += item.willpower unless item.willpower.nil?
    end

    def level_up
        # Increase level
        update(level: level + 1)

        if [25, 50, 75, 100].include?(level)
            self.skill_points += 1
        end

        # Calculate the remaining experience after leveling up
        remaining_experience = experience - required_experience_for_next_level

        # Increase some stats per level
        self.health += 10

        update_required_experience_for_next_level

        update(experience: remaining_experience)
    end

    def update_required_experience_for_next_level
        self.required_experience_for_next_level = (500 * (1.1 ** (self.level - 1))).round
    end

    def add_item_to_inventory(item)
        inventory = Inventory.find_or_create_by(character_id: id)
        item.update(inventory_id: inventory.id)
    end

    def remove_item_from_inventory(item)
        self.inventory.items.delete(item)
    end

    def unequip_one_handed_weapon(main_hand_item)
        return unless main_hand_item
        # Add the one-handed weapon back to the inventory
        add_item_to_inventory(main_hand_item)
        # Modify stats based on the unequipped one-handed weapon
        revert_stats_based_on_item(main_hand_item)
        # Clear the character's main hand
        self.main_hand = nil
    end
    def equip_one_handed_weapon(item)
        Rails.logger.debug("Before equipping one-handed : #{main_hand_item.inspect}")
        if main_hand_item.nil?
            # No existing weapon in the main hand
            self.main_hand = item
            modify_stats_based_on_item(item)
        elsif main_hand_item.present? && off_hand_item.nil?
            # No existing one-handed weapon in the off-hand but one in the main-hand
            self.off_hand = item
            # Remove the new weapon from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped weapon
            modify_stats_based_on_item(item)
        else
            # Replace the existing one-handed weapon in main-hand and move it to the inventory
            unequip_helmet(main_hand_item)
            self.main_hand = item
            # Remove the new weapon from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped weapon
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping one-handed : #{main_hand_item.inspect}")
    end
    
    def unequip_shield(off_hand_item)
        return unless off_hand_item
        # Add the shield/weapon back to the inventory
        add_item_to_inventory(off_hand_item)
        # Modify stats based on the unequipped shield/weapon
        revert_stats_based_on_item(off_hand_item)
        # Clear the character's off hand
        self.off_hand_item = nil
    end
    def equip_shield(item)
        Rails.logger.debug("Before equipping shield : #{off_hand_item.inspect}")
        if off_hand_item.nil?
            # No existing weapon in the off hand
            self.off_hand_item = item
            modify_stats_based_on_item(item)
        elsif main_hand&.two_handed_only
            # Unequip the existing two-handed weapon in main-hand and move it to the inventory
            unequip_two_handed_weapon
            self.off_hand_item = item
            # Remove the new weapon from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped weapon
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping shield : #{off_hand_item.inspect}")
    end

    def unequip_two_handed_weapon(main_hand_item)
        return unless main_hand_item
        # Add the two-handed weapon back to the inventory
        add_item_to_inventory(main_hand_item)
        # Modify stats based on the unequipped two-handed weapon
        revert_stats_based_on_item(main_hand_item)
        # Clear the character's main hand
        self.main_hand_item = nil
    end
    def equip_two_handed_weapon(item)
        Rails.logger.debug("Before equipping two-handed : #{main_hand_item.inspect}")
        if main_hand_item.nil? && off_hand_item.nil?
            # No existing weapon in main and off hand
            # Equip the weapon in the main hand
            self.main_hand_item = item
            # Remove the two-handed weapon from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped weapon
            modify_stats_based_on_item(item)
        elsif off_hand_item.present? && main_hand_item.nil?
            # Remove off-hand to equip two-handed weapon
            unequip_shield(off_hand_item)
            self.main_hand_item = item
            # Remove the new weapon from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped weapon
            modify_stats_based_on_item(item)
        else
            # Replace the existing weapon
            unequip_one_handed_weapon(main_hand_item)
            self.main_hand = item
            # Remove the new weapon from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped weapon
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping two-handed : #{main_hand_item.inspect}")
    end

    def unequip_helmet(head_item)
        return unless head_item
        # Add the helmet back to the inventory
        add_item_to_inventory(head_item)
        # Modify stats based on the removed helmet
        revert_stats_based_on_item(head_item)
        # Clear the character's helmet
        self.head_item = nil
    end
    def equip_helmet(item)
        Rails.logger.debug("Before equipping helmet: #{head_item.inspect}")
        if head_item.nil?
            # No existing helmet
            self.head_item = item
            # Remove the helmet from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped helmet
            modify_stats_based_on_item(item)
        else
            # Replace the existing helmet
            unequip_helmet(head_item)
            self.head_item = item
            # Remove the new helmet from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped helmet
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping helmet: #{head_item.inspect}")
    end

    def unequip_chest(chest_item)
        return unless chest_item
        # Add the chest back to the inventory
        add_item_to_inventory(chest_item)
        # Modify stats based on the removed chest
        revert_stats_based_on_item(chest_item)
        # Clear the character's chest
        self.chest_item = nil
    end
    def equip_chest(item)
        Rails.logger.debug("Before equipping chest: #{chest_item.inspect}")
        if chest_item.nil?
            # No existing chest
            self.chest_item = item
            # Remove the chest from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped chest
            modify_stats_based_on_item(item)
        else
            # Replace the existing chest
            unequip_helmet(chest_item)
            self.chest_item = item
            # Remove the new chest from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped chest
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping chest: #{chest_item.inspect}")
    end

    def unequip_legs(legs_item)
        return unless legs_item
        # Add the legs back to the inventory
        add_item_to_inventory(legs_item)
        # Modify stats based on the removed legs
        revert_stats_based_on_item(legs_item)
        # Clear the character's legs
        self.legs_item = nil
    end
    def equip_legs(item)
        Rails.logger.debug("Before equipping legs: #{legs_item.inspect}")
        if legs_item.nil?
            # No existing legs
            self.legs_item = item
            # Remove the legs from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped legs
            modify_stats_based_on_item(item)
        else
            # Replace the existing legs
            unequip_helmet(legs_item)
            self.legs_item = item
            # Remove the new legs from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped legs
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping legs: #{legs_item.inspect}")
    end

    def unequip_amulet(neck_item)
        return unless neck_item
        # Add the neck back to the inventory
        add_item_to_inventory(neck_item)
        # Modify stats based on the removed neck
        revert_stats_based_on_item(neck_item)
        # Clear the character's neck
        self.neck_item = nil
    end
    def equip_amulet(item)
        Rails.logger.debug("Before equipping amulet: #{neck_item.inspect}")
        if neck_item.nil?
            # No existing neck
            self.neck_item = item
            # Remove the neck from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped neck
            modify_stats_based_on_item(item)
        else
            # Replace the existing neck
            unequip_amulet(neck_item)
            self.neck_item = item
            # Remove the new neck from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped neck
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping amulet: #{neck_item.inspect}")
    end

    def unequip_ring(finger1_item)
        return unless finger1_item
        # Add the ring back to the inventory
        add_item_to_inventory(finger1_item)
        # Modify stats based on the unequipped ring
        revert_stats_based_on_item(finger1_item)
        # Clear the character's ring
        self.finger1_item = nil
    end
    def equip_ring(item)
        Rails.logger.debug("Before equipping ring: #{finger1_item.inspect} - #{finger2_item.inspect}")
        if finger1_item.nil?
            # No existing ring in finger1, simply equip the new one
            self.finger1_item = item
            # Remove the ring from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped ring
            modify_stats_based_on_item(item)
        elsif finger2_item.nil? & finger1_item.present?
            # No existing ring in finger2, but one in finger1
            self.finger2_item = item
            # Remove the ring from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped ring
            modify_stats_based_on_item(item)
        else
            # Replace the existing ring in finger1 and move it to the inventory
            unequip_ring(finger1_item)
            self.finger1_item = item
            # Remove the new ring from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped ring
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping ring: #{finger1_item.inspect} - #{finger2_item.inspect}")
    end

    def unequip_waist(waist_item)
        return unless waist_item
        # Add the waist back to the inventory
        add_item_to_inventory(waist_item)
        # Modify stats based on the removed waist
        revert_stats_based_on_item(waist_item)
        # Clear the character's neck
        self.waist_item = nil
    end
    def equip_waist(item)
        Rails.logger.debug("Before equipping waist: #{waist_item.inspect}")
        if waist_item.nil?
            # No existing waist
            self.waist_item = item
            # Remove the waist from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped waist
            modify_stats_based_on_item(item)
        else
            # Replace the existing waist
            unequip_waist(waist_item)
            self.waist_item = item
            # Remove the new waist from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped waist
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping waist: #{waist_item.inspect}")
    end

    def unequip_hands(hands_item)
        return unless hands_item
        # Add the hands back to the inventory
        add_item_to_inventory(hands_item)
        # Modify stats based on the removed hands
        revert_stats_based_on_item(hands_item)
        # Clear the character's hands
        self.hands_item = nil
    end
    def equip_hands(item)
        Rails.logger.debug("Before equipping hands: #{hands_item.inspect}")
        if hands_item.nil?
            # No existing hands
            self.hands_item = item
            # Remove the hands from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped hands
            modify_stats_based_on_item(item)
        else
            # Replace the existing hands
            unequip_amulet(hands_item)
            self.hands_item = item
            # Remove the new hands from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped hands
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping hands: #{hands_item.inspect}")
    end

    def unequip_feet(feet_item)
        return unless feet_item
        # Add the feet back to the inventory
        add_item_to_inventory(feet_item)
        # Modify stats based on the removed feet
        revert_stats_based_on_item(feet_item)
        # Clear the character's feet
        self.feet_item = nil
    end
    def equip_feet(item)
        Rails.logger.debug("Before equipping feet: #{feet_item.inspect}")
        if feet_item.nil?
            # No existing feet
            self.feet_item = item
            # Remove the feet from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped feet
            modify_stats_based_on_item(item)
        else
            # Replace the existing feet
            unequip_feet(feet_item)
            self.feet_item = item
            # Remove the new feet from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped feet
            modify_stats_based_on_item(item)
        end
        Rails.logger.debug("After equipping feet: #{feet_item.inspect}")
    end



    def max_characters
        errors.add(:base, "You can't have more than 3 characters.") if user.characters.count >= 3
    end

end