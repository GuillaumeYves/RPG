def create_monster( monster_name, health, attack, armor, magic_resistance, spellpower, strength, intelligence, luck, willpower, agility, image_path )
    monster = Monster.create!(
        monster_name: monster_name,
        health: health,
        attack: attack,
        armor: armor,
        magic_resistance: magic_resistance,
        spellpower: spellpower,
        strength: strength,
        intelligence: intelligence,
        luck: luck,
        willpower: willpower,
        agility: agility,
    )
    image_filename = "#{monster.id}_#{File.basename(image_path)}"
    monster.monster_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end
    begin 
        # Monster id 1
        create_monster("Bloodmancer", 1500, 250, 150, 150, 250, 300, 300, 300, 300, 300, 'app/assets/images/monsters/bloodmancer.jpg')
        
        # Monster id 2
        create_monster("Centaur", 1500, 250, 150, 150, 250, 300, 300, 300, 300, 300, 'app/assets/images/monsters/centaur.jpg')
        
        # Monster id 3
        create_monster("Cultist", 1500, 250, 150, 150, 250, 300, 300, 300, 300, 300, 'app/assets/images/monsters/cultist.jpg')

        # Monster id 4
        create_monster("Demon", 1500, 250, 150, 150, 250, 300, 300, 300, 300, 300, 'app/assets/images/monsters/demon.jpg')

        # Monster id 5
        create_monster("Demon General", 1500, 250, 150, 150, 250, 300, 300, 300, 300, 300, 'app/assets/images/monsters/demongeneral.jpg')

        # Monster id 6
        create_monster("Kolkur", 3000, 500, 300, 300, 500, 600, 600, 600, 600, 600, 'app/assets/images/monsters/kolkur.jpg')

        # Monster id 7
        create_monster("Renegade", 1500, 250, 150, 150, 250, 300, 300, 300, 300, 300, 'app/assets/images/monsters/renegade.jpg')

        # Monster id 8
        create_monster("Skeleton", 1500, 250, 150, 150, 250, 300, 300, 300, 300, 300, 'app/assets/images/monsters/skeleton.jpg')

        # Monster id 9
        create_monster("Vampire", 300, 15, 5, 5, 15, 10, 10, 10, 10, 10, 'app/assets/images/monsters/vampire.jpg')

    end