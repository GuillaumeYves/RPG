    def create_hunt(name, experience_reward, monster_id, description, difficulty, level_requirement, gold_reward, energy_cost)
    monster = Monster.find_by(id: monster_id)

    case difficulty
    when 2
        experience_reward *= 1.4
        gold_reward *= 1.4
        energy_cost *= 1.2
    when 3
        experience_reward *= 1.6
        gold_reward *= 1.6
        energy_cost *= 1.3
    when 4
        experience_reward *= 1.8
        gold_reward *= 1.8
        energy_cost *= 1.5
    end

    Hunt.create!(
        name: name,
        experience_reward: experience_reward.round,
        monster_id: monster_id,
        description: description,
        hunt_difficulty: difficulty,
        level_requirement: level_requirement,
        gold_reward: gold_reward.round,
        energy_cost: energy_cost.round
    )
    end

    # Hunt for level 1
    create_hunt(
    "The stench of blood",
    50, # XP reward
    9,  # Monster ID
    "A patrol has been sent to a nearby camp two days ago at night. Poor bastards have been slaughtered by what seems to be a vampire. Track him down before his curse spreads.",
    1,  # Difficulty
    1,  # Level required
    1,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 10
    create_hunt(
    "Bones and rot",
    110, # XP reward
    8,  # Monster ID
    "More and more tombs have been profaned lately and we can't seem to catch the culprit. The bodies are most likely taken away and used for dark magic by a necromancer. Find him and make him pay.",
    1,  # Difficulty
    10, # Level required
    1,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 20
    create_hunt(
    "The centaur",
    305,# XP reward
    2,  # Monster ID
    "A wandering centaur has been seen roaming the lands, stealing weapons from the forge. Retrieve the weapons and scare him off.",
    1,  # Difficulty
    20, # Level required
    2,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 30
    create_hunt(
    "Scales and claws",
    780,# XP reward
    14,  # Monster ID
    "For some reason, Drakkens are wandering out of their isles. That could quickly become a problem if we don't drive them back.
    You know what you have to do.",
    1,  # Difficulty
    30, # Level required
    2,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 40
    create_hunt(
    "Danger from beyond",
    2055, # XP reward
    4,  # Monster ID
    "Demonists are always trying to bind powerful demons to their will, but it seems like this time they failed to keep their new 'friend' in check. Send that creature back to its realm.",
    1,  # Difficulty
    40, # Level required
    4,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 50
    create_hunt(
    "Crimson Magic",
    5332, # XP reward
    1,  # Monster ID
    "The blood cult is summoning blood elementals all around the kingdom, we must put an end to this and quickly.",
    1,  # Difficulty
    50, # Level required
    4,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 60
    create_hunt(
    "Cult of the Void",
    6830, # XP reward
    3,  # Monster ID
    "Void cultists are attacking our encampments to weaken our troops, show them no mercy.",
    1,  # Difficulty
    60, # Level required
    5,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 70
    create_hunt(
    "Fires of hatred",
    7872, # XP reward
    6,  # Monster ID
    "With all the death and battles lately, the soil is filled with anger... And that has drawn the attention of Kolkurs. We need to push them back before we're overrun.",
    1,  # Difficulty
    70, # Level required
    5,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 80
    create_hunt(
    "Lieutenant of the Beyond",
    8685, # XP reward
    5,  # Monster ID
    "The armies of the Beyond are overwhelming us, we need to get rid of their Lieutenant to drive them back.",
    1,  # Difficulty
    80, # Level required
    6,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 90
    create_hunt(
    "Rebel forces",
    9815, # XP reward
    7,  # Monster ID
    "As the armies of the beyond grow stronger, more and more soldiers are seen betraying their kingdoms in hopes to find a way to survive.
    Some of them are starting to pillage nearby villages and we must protect them above all else.",
    1,  # Difficulty
    90, # Level required
    8,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 100 with difficulty 1
    create_hunt(
    "The Crimson Legion 1",
    10478, # XP reward
    10,  # Monster ID
    "Some Deathwalkers of the Crimson Legion are delighted to see the amount of death and decay the war is causing.
    They are using the bodies of fallen warriors as puppets to do their bidding. Soldiers have seen two of them attacking aimlessly around the mines.
    Get rid of them and burn the bodies.",
    1,  # Difficulty
    100, # Level required
    10,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 100 with difficulty 2
    create_hunt(
    "The Crimson Legion 2",
    10478, # XP reward
    11,  # Monster ID
    "Some Deathwalkers of the Crimson Legion are delighted to see the amount of death and decay the war is causing.
    They are using the bodies of fallen warriors as puppets to do their bidding. Soldiers have seen two of them attacking aimlessly around the mines.
    Get rid of them and burn the bodies.",
    2,  # Difficulty
    100, # Level required
    10,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 100 with difficulty 3
    create_hunt(
    "A flying menace",
    10478, # XP reward
    12,  # Monster ID
    "I have spotted a Drakhon flying over our livestock and it's taking great pleasure in killing most of it. Those things are sadistic beings.
    Kill it and try to bring some of its scales back to the forge. We can surely make something out of it.",
    3,  # Difficulty
    100, # Level required
    10,  # Gold reward
    5   # Energy cost
    )

    # Hunt for level 100 with difficulty 4
    create_hunt(
    "Wrath of the wilderness",
    10478, # XP reward
    13,  # Monster ID
    "We've sent some soldiers to retrieve resources, as we're starting to run low on everything... But only one returned.
    He said they have been attacked by something in the woods big enough to sent some of them flying when hit. I think you might be up to the challenge.",
    4,  # Difficulty
    100, # Level required
    10,  # Gold reward
    5   # Energy cost
    )
