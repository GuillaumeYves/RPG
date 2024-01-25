def create_item(name, item_type, level_requirement, rarity, stats = {}, description, image_path)
    item = Item.create!(
        name: name,
        item_type: item_type,
        level_requirement: level_requirement,
        rarity: rarity,
        description: description,
    )
    item.update(stats)
    # Generate a unique filename for each image using the item's ID
    image_filename = "#{item.id}_#{File.basename(image_path)}"
    item.item_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end

    begin
        create_item("Oregofol, blade of the damned", "One-handed Sword", 100, "Legendary", { attack: 277, health: -111, armor: -33, magic_resistance: -33 }, "'Take it from me... It will take your soul long before you can give it back.' - Elodon", 'app/assets/images/legendary_items/oregofol.jpg')
        
        create_item("Dying Sun", "One-handed Sword", 55, "Legendary", { spellpower: 96, luck: 6, intelligence: 25 }, "Remnants of a fiery power linger in this blade.", 'app/assets/images/legendary_items/dyingsun.jpg')
        
        create_item("Executioner", "Two-handed Axe", 80, "Legendary", { attack: 195, strength: 30, luck: 11 }, "This axe is said to be haunted by the souls of its victims.", 'app/assets/images/legendary_items/executioner.jpg')
        
        create_item("Fire and Ice", "One-handed Mace", 42, "Legendary", { attack: 53, spellpower: 53, willpower: 8 }, "Forged in the deepest mountain of Hammir.", 'app/assets/images/legendary_items/fireandice.jpg')
        
        create_item("Crystalised Power", "Dagger", 35, "Legendary", { spellpower: 60, intelligence: 10, luck: 4 }, "Mages of Ciradyll captured the essence of a powerful entity and trapped it within this blade.", 'app/assets/images/legendary_items/crystalisedpower.jpg')

        create_item("Oshu'un", "Two-Handed Mace", 66, "Legendary", { spellpower: 130, intelligence: 22, willpower: 9 }, "Legends say that this weapon is a holy relic gifted by the gods during the battle of Dumhor.", 'app/assets/images/legendary_items/oshuun.jpg')

        create_item("Wall of Pain", "Shield", "Legendary", { health: 30, armor: -12, magic_resistance: -12, strength: 3, willpower: -3 }, "You can feel your body break slowly with each attack blocked.", 'app/assets/images/legendary_items/wallofpain.jpg')

        create_item("Crown of Valor", "Helmet", "Legendary", { health: 20, armor: 10, magic_resistance: 10, willpower: 5 }, "'Bring me more of these fiends! None of them shall strike me down!' - Ikatus", 'app/assets/images/legendary_items/crownofvalor.jpg')

        create_item("Oath of the Ancients", "Chest", "Legendary", { health: 15, armor: 15, magic_resistance: -10, willpower: 3, intelligence: -5, strength: 3 }, "They have sworn to defend their people, but what can a warrior do against a cataclysm?", 'app/assets/images/legendary_items/oathoftheancients.jpg')

        create_item("Shard of the Gods", "Amulet", "Legendary", { health: 10, strength: 3, intelligence: 3, luck: 3, willpower: 3 }, "A strange glow emanates from this amulet when the sun shines upon it.", 'app/assets/images/legendary_items/shardofthegods.jpg')
        
        create_item("Devotion to the Light", "Ring", "Legendary", { attack: 4, spellpower: 4, health: 10 }, "Keep faith in the light, it always finds a way through the dark.", 'app/assets/images/legendary_items/devotiontothelight.jpg')
        
        create_item("Perseverance", "Ring", "Legendary", { willpower: 5, health: 20 }, "You persevere through the pain, for it is the only way to achieve victory.", 'app/assets/images/legendary_items/perseverance.jpg')
    end