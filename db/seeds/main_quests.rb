    def create_quest(name, experience_reward, quest_type, quest_objective, description, level_requirement, gold_reward)
        Quest.create!(
            name: name,
            experience_reward: experience_reward.round,
            quest_type: quest_type,
            quest_objective: quest_objective,
            description: description,
            level_requirement: level_requirement,
            gold_reward: gold_reward.round,
        )
    end

    # Starting quest
    create_quest(
    "Humble begginings",
    50, # XP reward
    "Main Quest",
    "Speak to Rudy",
    "You are a new recruit in the army of the kingdom. Go visit Rudy and get your instructions.",
    1,  # Level required
    1,  # Gold reward
    )


    create_quest(
    "The first task",
    100, # XP reward
    "Main Quest",
    "Speak to Milena",
    "Rudy asked you to participate in your first hunt. Milena can tell you more about this.",
    1,  # Level required
    1,  # Gold reward
    )

    create_quest(
    "A new threat",
    300, # XP reward
    "Main Quest",
    "Speak to Leo",
    "Something seems to worry the armies of Tedorha but your rank does not allow you to learn much more.
    Find Leo, maybe he can answer some of your questions.",
    10,  # Level required
    1,  # Gold reward
    )

    create_quest(
    "The great Beyond",
    1000, # XP reward
    "Main Quest",
    "Speak to Rudy",
    "The menace is clear; the Beyond is coming back for Tedorha to claim its powerful artifact.
    You are a recruit no longer, but now a defender of Tedorha.",
    30,  # Level required
    2,  # Gold reward
    )

    create_quest(
    "Aldva the power hungry",
    3000, # XP reward
    "Main Quest",
    "Speak to Rudy",
    "Aldva was a powerful mage that left the kingdom long ago.
    She was presumed dead until her attack on Ciradyll in hopes of finding a new artifact.
    We must learn more about her intentions before trying anything.",
    40,  # Level required
    3,  # Gold reward
    )

    create_quest(
    "Danger from Karguk",
    5000, # XP reward
    "Main Quest",
    "Speak to Rudy",
    "Kefren has gone mad and is leading the orcs against the other kingdoms.
    We must stop him before we get to fight back another Orc invasion that could weaken our defences against the Beyond.",
    50,  # Level required
    5,  # Gold reward
    )
