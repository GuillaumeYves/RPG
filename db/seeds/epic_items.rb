#Epic items stats are increased by 5%
def create_item(name, item_type, item_class, level_requirement, gold_price, rarity, stats = {}, image_path)
    item = Item.create!(
        name: name,
        item_type: item_type,
        item_class: item_class,
        level_requirement: level_requirement,
        gold_price: gold_price,
        rarity: rarity,
    )
    item.update(stats)
    image_filename = "#{item.id}_#{File.basename(image_path)}"
    item.item_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end

    begin 
        create_item("Blackfang", "One-handed Weapon", "Dagger", 100, 36750, "Epic", { health: 315, attack: 157, strength:52, luck: 52, critical_strike_chance: 5.25, critical_strike_damage: 0.52}, 'app/assets/images/epic_items/blackfang.jpg')
               
        create_item("Blackflame Reaper", "Two-handed Weapon", "Axe", 80, 55125, "Epic", { health: 420, attack: 252, strength: 84}, 'app/assets/images/epic_items/blackflamereaper.jpg')

        create_item("Burning Hatred", "Head", "Plate", 100, 52500, "Epic", { health: 420, luck: 105, armor: 47, magic_resistance: 23 }, 'app/assets/images/epic_items/burninghatred.jpg')
               
        create_item("Champion of Light", "Chest", "Plate", 60, 31500, "Epic", { health: 315, strength: 31, intelligence: 31, armor: 31, magic_resistance: 16 }, 'app/assets/images/epic_items/championoflight.jpg')

        create_item("Crown of Valor", "Head", "Plate", 30, 15750, "Epic", { health: 126, willpower: 31, armor: 14, magic_resistance: 7 }, 'app/assets/images/epic_items/crownofvalor.jpg')
        
        create_item("Dying Sun", "One-handed Weapon", "Sword", 90, 47250, "Epic", { health: 283, spellpower: 189, intelligence: 52, luck: 42 }, 'app/assets/images/epic_items/dyingsun.jpg')

        create_item("Emissary of Twilight", "Two-handed Weapon", "Staff", 40, 31500, "Epic", { health: 210, spellpower: 126, intelligence: 42, magic_resistance: 21 }, 'app/assets/images/epic_items/emissaryoftwilight.jpg')
        
        create_item("Fendel's Determination", "Feet", "Leather", 100, 52500, "Epic", { health: 210, strength: 31, agility: 31, luck: 42, armor:31, magic_resistance: 16 }, 'app/assets/images/epic_items/fendelsdetermination.jpg')

        create_item("Fire and Ice", "One-handed Weapon", "Mace", 70, 36750, "Epic", { health: 220, attack: 73, spellpower: 73, intelligence: 31, strength: 31, willpower: 10  }, 'app/assets/images/epic_items/fireandice.jpg')
       
        create_item("Footsteps of Wisdom", "Feet", "Cloth", 100, 52500, "Epic", { health: 105, intelligence: 105, armor: 21, magic_resistance: 21 }, 'app/assets/images/epic_items/footstepsofwisdom.jpg')
        
        create_item("Garnments of Miracles", "Chest", "Cloth", 100, 52500, "Epic", { health: 315, intelligence: 63, luck: 42, armor: 31, magic_resistance: 31 }, 'app/assets/images/epic_items/garnmentsofmiracles.jpg')

        create_item("Grasp of Condemned Kings", "Hands", "Plate", 100, 52500, "Epic", { health: 315, strength: 63, willpower: 42, armor: 42, magic_resistance: 21 }, 'app/assets/images/epic_items/graspofcondemnedkings.jpg')
  
        create_item("Pact of Assassination", "Chest", "Leather", 50, 26250, "Epic", { health: 210, strength: 31, agility: 21, armor: 21, magic_resistance: 10 }, 'app/assets/images/epic_items/pactofassassination.jpg')
  
        create_item("Prophecy", "Two-handed Weapon", "Mace", 100, 78750, "Epic", { health: 525, attack: 105, spellpower: 105, intelligence: 42, strength: 42, willpower: 10  }, 'app/assets/images/epic_items/prophecy.jpg')

        create_item("Rise of the Phoenix", "One-handed Weapon", "Sword", 40, 21000, "Epic", { health: 126, spellpower: 84, intelligence: 42 }, 'app/assets/images/epic_items/riseofthephoenix.jpg')

        create_item("Spire of Flames", "Two-handed Weapon", "Staff", 60, 47250, "Epic", { health: 315, spellpower: 189, intelligence: 63, magic_resistance: 31 }, 'app/assets/images/epic_items/spireofflames.jpg')
    
        create_item("Waistguard of Kings", "Waist", "Belt", 100, 52500, "Epic", { health: 525, agility: 52, strength: 52}, 'app/assets/images/epic_items/waistguardofkings.jpg')
    
        create_item("Wall of Pain", "Shield", "Great Shield", 50, 26250, "Epic", { health: 367, strength: 26, willpower: 26, armor:52, magic_resistance:52 }, 'app/assets/images/epic_items/wallofpain.jpg')
    end