Dir[File.join(Rails.root, "db", "seeds", "*.rb")].sort.each do |seed|

  puts "Seeding..."

  load seed

  puts "Seeding complete."


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