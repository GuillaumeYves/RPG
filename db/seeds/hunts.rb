    def create_hunt(name, experience_reward, monster_id, description, difficulty, level_requirement, gold_reward)
    monster = Monster.find_by(id: monster_id)
    
    Hunt.create!(
        name: name,
        experience_reward: experience_reward,
        monster_id: monster_id,
        description: description,
        hunt_difficulty: difficulty,
        level_requirement: level_requirement,
        gold_reward: gold_reward
    )
    end
  
    # Hunt for level 1
    create_hunt(
    "The stench of blood",
    50,
    9,
    "A patrol has been sent to a nearby camp two days ago at night. Poor bastards have been slaughtered by what seems to be a vampire. Track him down before his curse spreads.",
    1,
    1,
    1
    )

    create_hunt(
    "Bones and rot",
    50,
    8,
    "More and more tombs have been profaned lately and we can't seem to catch the culprit. The bodies are most likely taken away and used for dark magic by a necromancer. Find him and make him pay.",
    1,
    7,
    1
    )

    create_hunt(
    "The centaur",
    50,
    2,
    "A wandering centaur has been seen roaming the lands, stealing weapons from the forge. Retrieve the weapons and scare him off.",
    1,
    12,
    1
    )

    create_hunt(
    "Danger from beyond",
    50,
    4,
    "Demonists are always trying to bind powerful demons to their will, but it seems like this time they failed to keep their new 'friend' in check. Send that creature back to its realm.",
    1,
    17,
    3
    )

    create_hunt(
    "Crimson Magic",
    50,
    1,
    "The blood cult is summoning blood elementals all around the kingdom, we must put an end to this and quickly.",
    1,
    50,
    5
    )

    create_hunt(
    "Cult of the Void",
    50,
    3,
    "Void cultists are attacking our encampments to weaken our troops, show them no mercy.",
    1,
    60,
    6
    )

    create_hunt(
    "Fires of hatred",
    50,
    6,
    "With all the death and battles lately, the soil is filled with anger... And that has drawn the attention of Kolkurs. We need to push them back before we're overrun.",
    1,
    100,
    10
    )

    create_hunt(
    "Lieutenant of the Beyond",
    50,
    5,
    "The armies of the Beyond are overwhelming us, we need to get rid of their Lieutenant to drive them back.",
    1,
    100,
    10
    )