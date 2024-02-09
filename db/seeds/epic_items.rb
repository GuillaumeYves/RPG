#Epic items stats are increased by 10%
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
        create_item("Blackfang", "One-handed Weapon", "Dagger", 100, "Epic", { attack: 165, strength: 55, intelligence: 55, critical_strike_chance: 5.5, critical_strike_damage: 0.55}, "The edge of this blade scorches the flesh of your foes.", 'app/assets/images/epic_items/blackfang.jpg')

        create_item("Champion of Light", "Chest", "Plate", 80, "Epic", { health: 440, armor: 88, magic_resistance: 88, intelligence: 44, strength: 44 }, "Use your faith as your shield for it will never fail you.", 'app/assets/images/epic_items/championoflight.jpg')
        
        create_item("Dying Sun", "One-handed Weapon", "Sword", 50, "Epic", { spellpower: 110, luck: 33, intelligence: 22 }, "Remnants of a fiery power linger in this blade.", 'app/assets/images/epic_items/dyingsun.jpg')
        
        create_item("Fire and Ice", "One-handed Weapon", "Mace", 70, "Epic", { attack: 77, spellpower: 77, willpower: 22, intelligence: 33, strength: 22 }, "Forged in the deepest mountain of Hammir.", 'app/assets/images/epic_items/fireandice.jpg')

        create_item("Footsteps of Wisdom", "Feet", "Cloth", 100, "Epic", { health: 220, armor: 44, magic_resistance: 44, intelligence: 110 }, "Knowledge flows through your entire body.", 'app/assets/images/epic_items/footstepsofwisdom.jpg')

        create_item("Garnments of Miracles", "Chest", "Cloth", 80, "Epic", { health: 352, armor: 70, magic_resistance: 70, intelligence: 66, luck: 44 }, "Miracles are only a fabric of weak minds.", 'app/assets/images/epic_items/garnmentsofmiracles.jpg')

        create_item("Hellbound", "Two-handed Weapon", "Axe", 100, "Epic", { attack: 330, strength: 110 }, "From the depths of Hell, forged by flame and agony.", 'app/assets/images/epic_items/hellbound.jpg')
                        
        create_item("Oath of the Ancients", "Chest", "Plate", 60, "Epic", { health: 330, armor: 66, magic_resistance: -33, intelligence: -33, strength: 66 }, "They have sworn to defend their people, but what can a warrior do against a cataclysm?", 'app/assets/images/epic_items/oathoftheancients.jpg')

        create_item("Oregofol, blade of the damned", "One-handed Weapon", "Sword", 100, "Epic", { attack: 220, health: -110, armor: -11, magic_resistance: -11 }, "'Take it from me... It will take your soul long before you can give it back.' - Elodon", 'app/assets/images/epic_items/oregofol.jpg')
                
        create_item("Prophecy", "Two-handed Weapon", "Mace", 40, "Epic", { attack: 66, spellpower: 66, luck: 22, strength: 22 }, "A prophecy told by mere butchers.", 'app/assets/images/epic_items/prophecy.jpg')

        create_item("Serpent Eye", "Finger", "Ring", 30, "Legendary", { agility: 22, luck: 11, health: 66}, "You can see the ring observing each of your movements.", 'app/assets/images/epic_items/serpenteye.jpg')

        create_item("Spire of Flames", "Two-handed Weapon", "Staff", 50, "Epic", { spellpower: 155, intelligence: 44, luck: 11, magic_resistance: 28 }, "A pyromancer's dream. An infinite source of fire and destruction.", 'app/assets/images/epic_items/spireofflames.jpg')
    
        create_item("Stranglers of lost Visions", "Hands", "Cloth", 100, "Epic", { health: 220, armor: 44, magic_resistance: 44, intelligence: 55, luck: 55 }, "Once owned by a blind sage, executed for unveiling the legion's secrets.", 'app/assets/images/epic_items/stranglersoflostvisions.jpg')

        create_item("Vengeful Guard", "Shield", "Great Shield", 100, "Epic", { health: 1100, armor: 110, magic_resistance: 110, willpower: 110 }, "'You will all tremble before my vengeance.' - Demos", 'app/assets/images/epic_items/vengefulguard.jpg')

        create_item("Walkers of Sunlight", "Feet", "Plate", 30, "Epic", { health: 99, armor: 20, magic_resistance: 20, willpower: 33 }, "Your footprints shine through the dark of the night.", 'app/assets/images/epic_items/walkersofsunlight.jpg')

        create_item("Wall of Pain", "Shield", "Great Shield", 100, "Epic", { health: 1100, armor: -27, magic_resistance: -27, strength: 110, attack: 110, willpower: -55 }, "You can feel your body break slowly with each attack blocked.", 'app/assets/images/epic_items/wallofpain.jpg')
        
        create_item("Wraith's Visage", "Head", "Leather", 70, "Epic", { health: 269, armor: 54, magic_resistance: 54, agility: 77 }, "A cursed helm that slowly claims your soul to turn you into a Wraith.", 'app/assets/images/epic_items/wraithsvisage.jpg')
    end