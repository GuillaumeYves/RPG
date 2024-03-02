#Legendary items stats are increased by 15%
def create_item(name, item_type, item_class, level_requirement, gold_price, rarity, stats = {}, description, image_path)
    item = Item.create!(
        name: name,
        item_type: item_type,
        item_class: item_class,
        level_requirement: level_requirement,
        gold_price: gold_price,
        rarity: rarity,
        description: description,
    )
    item.update(stats)
    image_filename = "#{item.id}_#{File.basename(image_path)}"
    item.item_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end

    begin
        create_item("Betrayal", "One-handed Weapon", "Dagger", 100, 57500, "Legendary", { health: 345, attack: 172, agility:92, luck: 23, critical_strike_chance: 5.75, critical_strike_damage: 0.57}, "Your lust for power led you to betray your own kin.", 'app/assets/images/legendary_items/betrayal.jpg')

        create_item("Broken Promise", "Finger", "Ring", 100, 57500, "Legendary", { health: 575, strength: 115, intelligence: 115, agility: 115, luck: 115 }, "The promise of a broken world, made by a broken god.", 'app/assets/images/legendary_items/brokenpromise.jpg')

        create_item("Cerberus", "Two-handed Weapon", "Mace", 100, 86250, "Legendary", { health: 575, attack: 345, strength: 63, willpower: 63 }, "You are now the guardian of the Beyond.", 'app/assets/images/legendary_items/cerberus.jpg')

        create_item("Cremation", "Two-handed Weapon", "Scythe", 100, 86250, "Legendary", { health: 575, necrosurge: 345, dreadmight: 63, willpower: 63 }, "Darken the skies with their ashes.", 'app/assets/images/legendary_items/cremation.jpg')

        create_item("Hellbound", "Two-handed Weapon", "Axe", 100, 86250, "Legendary", { health: 575, attack: 345, strength: 80, luck: 34 }, "Unleash the wrath of the underworld upon your foes and dominate the battlefield.", 'app/assets/images/legendary_items/hellbound.jpg')

        create_item("Karguk's Demise", "Two-handed Weapon", "Sword", 100, 86250, "Legendary", { health: 575, attack: 345, strength: 115 }, "The blade wielded by the king Yahrm, during the great invasion of the Orcs.", 'app/assets/images/legendary_items/karguksdemise.jpg')

        create_item("Nemesis", "Two-handed Weapon", "Staff", 100, 86250, "Legendary", { health: 575, spellpower: 345, intelligence: 92, luck: 23, magic_resistance: 57 }, "Become the enemy of a nation. The doom of an entire kingdom.", 'app/assets/images/legendary_items/nemesis.jpg')

        create_item("Nethil", "One-handed Weapon", "Sword", 100, 57500, "Legendary", { health: 345, attack: 115, spellpower: 115, strength: 34, intelligence: 34, luck: 46 }, "Go now, for the blade hungers for more souls.", 'app/assets/images/legendary_items/nethil.jpg')

        create_item("Thundercall", "Shield", "Small Shield", 100, 57500, "Legendary", { health: 575, armor: 46, magic_resistance: 138, intelligence: 46, willpower: 69 }, "The skies obey to your calling.", 'app/assets/images/legendary_items/thundercall.jpg')

        create_item("Triad's Gaze", "Neck", "Amulet", 100, 57500, "Legendary", { health: 575, critical_strike_chance: 11.5, critical_strike_damage: 1.15}, "They watch over you and give you power, as long as you obey.", 'app/assets/images/legendary_items/triadsgaze.jpg')

    end
