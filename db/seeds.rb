Dir[File.join(Rails.root, "db", "seeds", "*.rb")].sort.each do |seed|

  puts "Seeding..."

  load seed

  puts "Seeding complete."
end

def create_item(name, item_type, rarity, stats = {}, description, image_path)
    item = Item.create!(
        name: name,
        item_type: item_type,
        rarity: rarity,
        description: description
    )

    item.update(stats)

    # Generate a unique filename for each image using the item's ID
    image_filename = "#{item.id}_#{File.basename(image_path)}"
    
    item.item_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end

# Create multiple items using the create_item method
begin
    create_item("Oregofol, blade of the damned", "One-handed Weapon", "Legendary", { attack: 18, health: -12, strength: 3, willpower: -6 }, "'Take it from me... It will take your soul long before you can give it back. - Elodon'", 'app/assets/images/legendary_items/oregofol.jpg')
    
    create_item("Dying Sun", "One-handed Weapon", "Legendary", { strength: -3, luck: 3, intelligence: 8 }, "Remnants of a fiery power linger in this blade.", 'app/assets/images/legendary_items/dyingsun.jpg')
    
    create_item("Executioner", "Two-handed Weapon", "Legendary", { attack: 10, strength: 4, luck: 3 }, "'This axe is said to be haunted by the souls of its victims.'", 'app/assets/images/legendary_items/executioner.jpg')
    
    create_item("Wall of Pain", "Shield", "Legendary", { health: 30, armor: -12, magic_resistance: -12, strength: 3, willpower: -3 }, "You can feel your body break slowly with each attack blocked.", 'app/assets/images/legendary_items/wallofpain.jpg')

    create_item("Crown of Valor", "Helmet", "Legendary", { health: 20, armor: 10, magic_resistance: 10, willpower: 5 }, "'Bring me more of these fiends! None of them shall strike me down! - Ikatus'", 'app/assets/images/legendary_items/crownofvalor.jpg')

    create_item("Oath of the Ancients", "Chest", "Legendary", { health: 15, armor: 15, magic_resistance: -10, willpower: 3, intelligence: -5, strength: 3 }, "They have sworn to defend their people, but what can a warrior do against a cataclysm?", 'app/assets/images/legendary_items/oathoftheancients.jpg')

    create_item("Shard of the Gods", "Amulet", "Legendary", { health: 10, strength: 3, intelligence: 3, luck: 3, willpower: 3 }, "A strange glow emanates from this amulet when the sun shines upon it.", 'app/assets/images/legendary_items/shardofthegods.jpg')
    
    create_item("Devotion to the Light", "Ring", "Legendary", { attack: 4, spellpower: 4, health: 10 }, "'Keep faith in the light, for it always finds a way through the dark.'", 'app/assets/images/legendary_items/devotiontothelight.jpg')
    
    create_item("Perseverance", "Ring", "Legendary", { willpower: 5, health: 20 }, "You persevere through the pain, for it is the only way to achieve victory.", 'app/assets/images/legendary_items/perseverance.jpg')

    vampire = Monster.create!(monster_name: "Vampire")
    vampire.monster_image.attach(io: File.open('app/assets/images/monsters/vampire.jpg'), filename: 'vampire.jpg', content_type: 'image/jpeg')
    vampire.save!

    skeleton = Monster.create!(monster_name: "Skeleton")
    skeleton.monster_image.attach(io: File.open('app/assets/images/monsters/skeleton.jpg'), filename: 'skeleton.jpg', content_type: 'image/jpeg')
    skeleton.save!

    centaur = Monster.create!(monster_name: "Centaur")
    centaur.monster_image.attach(io: File.open('app/assets/images/monsters/centaur.jpg'), filename: 'centaur.jpg', content_type: 'image/jpeg')
    centaur.save!

    demon = Monster.create!(monster_name: "Demon")
    demon.monster_image.attach(io: File.open('app/assets/images/monsters/demon.jpg'), filename: 'demon.jpg', content_type: 'image/jpeg')
    demon.save!
    
    def create_hunt(name, experience_reward, monster_id, description, difficulty, level_requirement)
    Hunt.create!(
        name: name,
        experience_reward: experience_reward,
        monster_id: monster_id,
        description: description,
        hunt_difficulty: difficulty,
        level_requirement: level_requirement
    )
    end
  
  
    create_hunt(
    "The stench of blood",
    20,
    1,
    "A patrol has been sent to a nearby camp two days ago at night. Poor bastards have been slaughtered by what seems to be a vampire. Track him down before his curse spreads.",
    1,
    1
    )

    create_hunt(
    "Bones and rot",
    20,
    2,
    "More and more tombs have been profaned lately and we can't seem to catch the culprit. The bodies are most likely taken away and used for dark magic by a necromancer. Find him and make him pay.",
    1,
    1
    )

    create_hunt(
    "The centaur",
    20,
    3,
    "A wandering centaur has been seen roaming the lands, stealing weapons from the forge. Retrieve the weapons and scare him off.",
    1,
    1
    )

    create_hunt(
    "Danger from beyond",
    20,
    4,
    "Demonists are always trying to bind powerful demons to their will, but it seems like this time they failed to keep their new 'friend' in check. Send that creature back to its realm.",
    1,
    1
    )

rescue StandardError => e
  puts "Error in seed file: #{e.message}"
  puts e.backtrace
end