#Legendary items stats are increased by 15%
def create_item(name, item_type, item_class, level_requirement, rarity, stats = {}, description, image_path)
    item = Item.create!(
        name: name,
        item_type: item_type,
        item_class: item_class,
        level_requirement: level_requirement,
        rarity: rarity,
        description: description,
    )
    item.update(stats)
    image_filename = "#{item.id}_#{File.basename(image_path)}"
    item.item_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end

    begin 
        create_item("Betrayal", "One-handed Weapon", "Dagger", 100, "Legendary", { attack: 172, agility:92, luck: 23, critical_strike_chance: 5.75, critical_strike_damage: 0.57}, "'Climb the ranks of the army and assassinate the king... What a wonderful plan.' - Johei", 'app/assets/images/legendary_items/betrayal.jpg')
        
        create_item("Broken Promise", "Finger", "Ring", 100, "Legendary", { strength: 115, intelligence: 115, willpower: 115 }, "A broken promise made by a broken God.", 'app/assets/images/legendary_items/brokenpromise.jpg')

        create_item("Crown of Valor", "Head", "Plate", 80, "Legendary", { health: 368, armor: 74, magic_resistance: 74, willpower: 92 }, "'I will not surrender. I will not give in. And I will never let you win!' - Ikatus", 'app/assets/images/legendary_items/crownofvalor.jpg')

        create_item("Emissary of Twilight", "Two-handed Weapon", "Staff", 100, "Legendary", { spellpower: 345, intelligence: 115, magic_resistance: 57 }, "The sun creates while the moon heals. But the twilight only wants destruction.", 'app/assets/images/legendary_items/emissaryoftwilight.jpg')
        
        create_item("Grasp of Condemned Kings", "Hands", "Plate", 50, "Legendary", { health: 172, armor: -17, magic_resistance: -17, willpower: -23, strength: 34, luck: 23 }, "These gauntlets were once worn by honorable kings, all corrupted by greed and power.", 'app/assets/images/legendary_items/graspofcondemnedkings.jpg')

        create_item("Hands of Fate", "Hands", "Leather", 100, "Legendary", { health: 287, armor: 57, magic_resistance: 57, agility: 57, luck: 57 }, "You foresee every strike.", 'app/assets/images/legendary_items/handsoffate.jpg')

        create_item("Karguk's Demise", "Two-handed Weapon", "Sword", 100, "Legendary", { attack: 345, strength: 115, willpower: 115 }, "The blade wielded by the king Yahrm, during the great invasion of the Orcs.", 'app/assets/images/legendary_items/karguksdemise.jpg')
               
        create_item("Nemesis", "Two-handed Weapon", "Staff", 70, "Legendary", { spellpower: 241, intelligence: 46, luck: 34, magic_resistance: 40 }, "'Become the enemy of a nation... The doom of an entire kingdom.' - Ashalanor", 'app/assets/images/legendary_items/nemesis.jpg')

        create_item("Nethil", "One-handed Weapon", "Sword", 100, "Legendary", { attack: 115, spellpower: 115, strength: 34, agility: 34, luck: 46 }, "The sword only reveals its power when wielded by it's true master.", 'app/assets/images/legendary_items/nethil.jpg')

        create_item("Pact of Assassination", "Chest", "Leather", 100, "Legendary", { health: 517, armor: 103, magic_resistance: 103, agility: 115 }, "'A pact, a contract, an agreement. Call it what you want, it's nothing but a job to me.' - Rodal", 'app/assets/images/legendary_items/pactofassassination.jpg')

        create_item("Perseverance", "Finger", "Ring", 60, "Legendary", { strength: 23, intelligence: 23, willpower: 23, health: 138, critical_strike_chance: 3.45, critical_strike_damage: 0.34 }, "Persevere through the pain to achieve victory.", 'app/assets/images/legendary_items/perseverance.jpg')
        
        create_item("Rise of the Phoenix", "One-handed Weapon", "Sword", 100, "Legendary", { attack: 46, spellpower: 184, strength: 23, intelligence: 57, luck: 34 }, "From the ashes, the flame is born. From the ashes, power is reborn.", 'app/assets/images/legendary_items/riseofthephoenix.jpg')

        create_item("Treads of Vigor", "Feet", "Plate", 90, "Legendary", { health: 310, armor: 62, magic_resistance: 62, luck: 46, willpower: 57 }, "You will never feel the burden of your armor again.", 'app/assets/images/legendary_items/treadsofvigor.jpg')
        
        create_item("Triad's Gaze", "Neck", "Amulet", 100, "Legendary", { health: 315, intelligence: 46, strength: 69, critical_strike_chance: 11.5, critical_strike_damage: 1.15 }, "The Triad will grant you strength, as long as you obey.", 'app/assets/images/legendary_items/triadsgaze.jpg')

        create_item("Waistguard of Kings", "Waist", "Belt", 100, "Legendary", { health: 575, willpower: 46, agility: 69 }, "They wanted protection above all, and now only a fading memory remains.", 'app/assets/images/legendary_items/waistguardofkings.jpg')
    end