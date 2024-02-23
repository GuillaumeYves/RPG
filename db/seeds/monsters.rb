def create_monster( monster_name, health, attack, armor, magic_resistance, spellpower, necrosurge, strength, intelligence, luck, willpower, agility, dreadmight, image_path )
    monster = Monster.create!(
        monster_name: monster_name,
        health: health,
        attack: attack,
        spellpower: spellpower,
        necrosurge:necrosurge,
        armor: armor,
        magic_resistance: magic_resistance,
        strength: strength,
        intelligence: intelligence,
        luck: luck,
        willpower: willpower,
        agility: agility,
        dreadmight: dreadmight,
    )
    image_filename = "#{monster.id}_#{File.basename(image_path)}"
    monster.monster_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end
    begin
        # Monster id 1
        create_monster("Bloodmancer", 600, 40, 60, 1, 50, 50, 60, 60, 60, 60, 60, 60, 'app/assets/images/monsters/bloodmancer.jpg')

        # Monster id 2
        create_monster("Centaur", 300, 30, 12, 1, 20, 20, 30, 30, 30, 30, 30, 30, 'app/assets/images/monsters/centaur.jpg')

        # Monster id 3
        create_monster("Cultist", 700, 70, 20, 1, 60, 60, 70, 70, 70, 70, 70, 70, 'app/assets/images/monsters/cultist.jpg')

        # Monster id 4
        create_monster("Demon", 500, 50, 30, 1, 40, 40, 50, 50, 50, 50, 50, 50, 'app/assets/images/monsters/demon.jpg')

        # Monster id 5
        create_monster("Demon General", 900, 90, 10, 1, 80, 80, 90, 90, 90, 90, 90, 90, 'app/assets/images/monsters/demongeneral.jpg')

        # Monster id 6
        create_monster("Kolkur", 800, 20, 80, 1, 70, 70, 80, 80, 80, 80, 80, 80, 'app/assets/images/monsters/kolkur.jpg')

        # Monster id 7
        create_monster("Renegade", 1000, 100, 20, 1, 90, 90, 100, 100, 100, 100, 100, 100, 'app/assets/images/monsters/renegade.jpg')

        # Monster id 8
        create_monster("Skeleton", 200, 20, 2, 1, 10, 10, 20, 20, 20, 20, 20, 20, 'app/assets/images/monsters/skeleton.jpg')

        # Monster id 9
        create_monster("Vampire", 100, 10, 6, 1, 5, 5, 10, 10, 10, 10, 10, 10, 'app/assets/images/monsters/vampire.jpg')

        # Monster id 10
        create_monster("Crimson Legion Warrior", 1100, 110, 10, 1, 100, 100, 110, 110, 110, 110, 110, 110, 'app/assets/images/monsters/crimsonlegionwarrior.jpg')

        # Monster id 11
        create_monster("Crimson Legion Assassin", 1300, 120, 30, 1, 120, 120, 130, 130, 130, 130, 130, 130, 'app/assets/images/monsters/crimsonlegionassassin.jpg')

        # Monster id 12
        create_monster("Drakhon", 1500, 140, 20, 1, 140, 140, 150, 150, 150, 150, 150, 150, 'app/assets/images/monsters/drakhon.jpg')

        # Monster id 13
        create_monster("Sh'ytar", 1800, 60, 170, 1, 170, 170, 180, 180, 180, 180, 180, 180, 'app/assets/images/monsters/shytar.jpg')

        # Monster id 14
        create_monster("Drakken", 400, 40, 10, 1, 30, 30, 40, 40, 40, 40, 40, 40, 'app/assets/images/monsters/drakken.jpg')

    end
