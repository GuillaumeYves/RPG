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
        create_item("Betrayal", "One-handed Weapon", "Dagger", 100, 57500, "Legendary", { health: 345, attack: 172, global_damage: 0.12, agility: 207, luck: 138, critical_strike_chance: 5.75, critical_strike_damage: 0.57}, "Your lust for power led you to betray your own kin.", 'app/assets/images/legendary_items/betrayal.jpg')

        create_item("Broken Promise", "Finger", "Ring", 100, 57500, "Legendary", { health: 575, strength: 115, intelligence: 115, agility: 115, dreadmight: 115, luck: 115 }, "The promise of a broken world, made by a broken god.", 'app/assets/images/legendary_items/brokenpromise.jpg')

        create_item("Cerberus", "Two-handed Weapon", "Mace", 100, 86250, "Legendary", { health: 575, attack: 230, spellpower: 230, strength: 144, intelligence: 144, willpower: 57 }, "You are now the guardian of the Beyond.", 'app/assets/images/legendary_items/cerberus.jpg')

        create_item("Hellbound", "Two-handed Weapon", "Axe", 100, 86250, "Legendary", { health: 690, attack: 345, strength: 276, luck: 69 }, "Unleash the wrath of the underworld upon your foes.", 'app/assets/images/legendary_items/hellbound.jpg')

        create_item("Karguk's Demise", "Two-handed Weapon", "Sword", 100, 86250, "Legendary", { health: 575, attack: 402, strength: 115, agility: 115, willpower: 115 }, "The blade wielded by the king Yahrm, during the great invasion of the Orcs.", 'app/assets/images/legendary_items/karguksdemise.jpg')

        create_item("Nemesis", "Two-handed Weapon", "Staff", 100, 86250, "Legendary", { health: 575, spellpower: 345, intelligence: 230, luck: 115, magic_resistance: 57 }, "Become the enemy of a nation. The doom of an entire kingdom.", 'app/assets/images/legendary_items/nemesis.jpg')

        create_item("Nethil", "One-handed Weapon", "Sword", 100, 57500, "Legendary", { health: 345, necrosurge: 86, dreadmight: 345, global_damage: 0.06 }, "Go now, for the blade hungers for more souls.", 'app/assets/images/legendary_items/nethil.jpg')

        create_item("Ruler of Storms", "One-handed Weapon", "Mace", 100, 57500, "Legendary", { health: 345, attack: 172, spellpower: 172, strength: 122, intelligence: 122, luck: 50 }, "Shaping destiny with each resounding strike", 'app/assets/images/legendary_items/rulerofstorms.jpg')

        create_item("The Black Gate", "Shield", "Great Shield", 100, 86250, "Legendary", { health: 575, armor: 172, magic_resistance: 57, strength: 172, willpower: 172 }, "Unyielding, a sentinel against the encroaching shadows.", 'app/assets/images/legendary_items/theblackgate.jpg')

        create_item("Thundercall", "Shield", "Small Shield", 100, 57500, "Legendary", { health: 345, armor: 23, magic_resistance: 92, intelligence: 172, luck: 86, willpower: 86 }, "The skies obey to your calling.", 'app/assets/images/legendary_items/thundercall.jpg')

        create_item("Triad's Gaze", "Neck", "Amulet", 100, 57500, "Legendary", { health: 575, global_damage: 0.10, critical_strike_chance: 11.5, critical_strike_damage: 1.15}, "They watch over you and give you power, as long as you obey.", 'app/assets/images/legendary_items/triadsgaze.jpg')

        create_item("Ush'val", "One-handed Weapon", "Sword", 100, 57500, "Legendary", { health: 345, spellpower: 230, intelligence: 345, global_damage: 0.10 }, "The blade is whispering of arcane secrets and untold power.", 'app/assets/images/legendary_items/ushval.jpg')

    end
