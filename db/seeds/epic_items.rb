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
        create_item("Assassin's Quicksteps", "Feet", "Leather", 100, 52500, "Epic", { health: 210, agility: 315, armor: 31, magic_resistance: 15 }, 'app/assets/images/epic_items/assassinsquicksteps.jpg')

        create_item("Blackfang", "One-handed Weapon", "Dagger", 100, 36750, "Epic", { health: 315, attack: 157, strength: 189, agility: 63, luck: 63, critical_strike_chance: 5.25, critical_strike_damage: 0.52}, 'app/assets/images/epic_items/blackfang.jpg')

        create_item("Blackflame Reaper", "Two-handed Weapon", "Axe", 80, 55125, "Epic", { health: 420, attack: 252, strength: 252, willpower: 63}, 'app/assets/images/epic_items/blackflamereaper.jpg')

        create_item("Burning Hatred", "Head", "Plate", 100, 52500, "Epic", { health: 420, strength: 105, willpower: 105, luck: 105, armor: 47, magic_resistance: 23 }, 'app/assets/images/epic_items/burninghatred.jpg')

        create_item("Champion of Light", "Chest", "Plate", 60, 31500, "Epic", { health: 315, strength: 94, intelligence: 94, armor: 31, magic_resistance: 16 }, 'app/assets/images/epic_items/championoflight.jpg')

        create_item("Cloak of Forbidden Rites", "Chest", "Cloth", 100, 52500, "Epic", { health: 315, dreadmight: 157, willpower: 157, armor: 31, magic_resistance: 31 }, 'app/assets/images/epic_items/cloakofforbiddenrites.jpg')

        create_item("Crown of Twisted Souls", "Head", "Cloth", 100, 52500, "Epic", { health: 210, dreadmight: 94, intelligence: 220, armor: 26, magic_resistance: 26 }, 'app/assets/images/epic_items/crownoftwistedsouls.jpg')

        create_item("Crown of Valor", "Head", "Plate", 30, 15750, "Epic", { health: 126, willpower: 94, armor: 14, magic_resistance: 7 }, 'app/assets/images/epic_items/crownofvalor.jpg')

        create_item("Dying Sun", "One-handed Weapon", "Sword", 90, 47250, "Epic", { health: 283, spellpower: 189, intelligence: 94, agility: 94, luck: 94 }, 'app/assets/images/epic_items/dyingsun.jpg')

        create_item("Emissary of Twilight", "Two-handed Weapon", "Staff", 40, 31500, "Epic", { health: 210, spellpower: 126, intelligence: 126, magic_resistance: 21 }, 'app/assets/images/epic_items/emissaryoftwilight.jpg')

        create_item("Fendel's Determination", "Feet", "Leather", 100, 52500, "Epic", { health: 210, strength: 105, agility: 105, willpower: 105, armor:31, magic_resistance: 16 }, 'app/assets/images/epic_items/fendelsdetermination.jpg')

        create_item("Firelord's Barbute", "Head", "Plate", 100, 52500, "Epic", { health: 420, strength: 105, willpower: 105, intelligence: 105, armor: 47, magic_resistance: 23 }, 'app/assets/images/epic_items/firelordsbarbute.jpg')

        create_item("Fire and Ice", "One-handed Weapon", "Mace", 70, 36750, "Epic", { health: 220, attack: 147, spellpower: 147, intelligence: 110, strength: 110}, 'app/assets/images/epic_items/fireandice.jpg')

        create_item("Footsteps of Wisdom", "Feet", "Cloth", 100, 52500, "Epic", { health: 105, intelligence: 157, dreadmight: 157, armor: 21, magic_resistance: 21 }, 'app/assets/images/epic_items/footstepsofwisdom.jpg')

        create_item("Garnments of Miracles", "Chest", "Cloth", 100, 52500, "Epic", { health: 315, intelligence: 157, luck: 157, armor: 31, magic_resistance: 31 }, 'app/assets/images/epic_items/garnmentsofmiracles.jpg')

        create_item("Grasp of Condemned Kings", "Hands", "Plate", 100, 52500, "Epic", { health: 315, strength: 189, luck: 126, armor: 42, magic_resistance: 21 }, 'app/assets/images/epic_items/graspofcondemnedkings.jpg')

        create_item("Hood of Damned Fortune", "Head", "Leather", 100, 52500, "Epic", { health: 315, strength: 105, agility: 105, luck: 105, armor: 37, magic_resistance: 18 }, 'app/assets/images/epic_items/hoodofdamnedfortune.jpg')

        create_item("Pact of Assassination", "Chest", "Leather", 50, 26250, "Epic", { health: 210, strength: 79, agility: 79, armor: 21, magic_resistance: 10 }, 'app/assets/images/epic_items/pactofassassination.jpg')

        create_item("Prophecy", "Two-handed Weapon", "Mace", 100, 78750, "Epic", { health: 525, attack: 210, spellpower: 210, intelligence: 157, strength: 157}, 'app/assets/images/epic_items/prophecy.jpg')

        create_item("Rise of the Phoenix", "One-handed Weapon", "Sword", 40, 21000, "Epic", { health: 126, spellpower: 84, intelligence: 126 }, 'app/assets/images/epic_items/riseofthephoenix.jpg')

        create_item("Triad's Grasp", "Hands", "Cloth", 100, 52500, "Epic", { health: 105, intelligence: 189, luck: 126, armor: 21, magic_resistance: 21 }, 'app/assets/images/epic_items/triadsgrasp.jpg')

        create_item("Spire of Flames", "Two-handed Weapon", "Staff", 60, 47250, "Epic", { health: 315, spellpower: 189, intelligence: 189, magic_resistance: 31 }, 'app/assets/images/epic_items/spireofflames.jpg')

        create_item("Vision of the Damned", "Head", "Cloth", 100, 52500, "Epic", { health: 210, dreadmight: 262, luck: 52, armor: 26, magic_resistance: 26 }, 'app/assets/images/epic_items/visionofthedamned.jpg')

        create_item("Waistguard of Kings", "Waist", "Belt", 100, 52500, "Epic", { health: 525, agility: 126, strength: 126, dreadmight: 63}, 'app/assets/images/epic_items/waistguardofkings.jpg')

        create_item("Walkers of Time", "Feet", "Cloth", 100, 52500, "Epic", { health: 105, intelligence: 105, willpower: 210, armor: 21, magic_resistance: 21 }, 'app/assets/images/epic_items/walkersoftime.jpg')

        create_item("Wall of Pain", "Shield", "Great Shield", 50, 26250, "Epic", { health: 262, strength: 79, willpower: 79, armor: 52, magic_resistance: 52 }, 'app/assets/images/epic_items/wallofpain.jpg')

        create_item("Zealous Crusade", "Head", "Plate", 100, 52500, "Epic", { health: 420, strength: 126, luck: 189, armor: 47, magic_resistance: 23 }, 'app/assets/images/epic_items/zealouscrusade.jpg')
    end
