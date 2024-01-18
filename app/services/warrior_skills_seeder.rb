class WarriorSkillsSeeder
  attr_reader :character, :warrior_skills

  def initialize(character)
    @character = character
    @warrior_skills = []
  end

  def seed_skills
    warrior_class = "warrior"

    rage = Skill.create(
      name: "Rage",
      description: "When getting hit, your Attack increases by 0.5%.",
      row: 1,
      level_requirement: 25,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'rage.jpg')
    rage.skill_image.attach(io: File.open(image_path), filename: 'rage.jpg', content_type: 'image/jpeg')
    warrior_skills << rage

    defensive_stance = Skill.create(
      name: "Defensive stance",
      description: "You take 10% reduced damage but you deal 10% reduced damage.",
      row: 1,
      level_requirement: 25,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'defensivestance.jpg')
    defensive_stance.skill_image.attach(io: File.open(image_path), filename: 'defensivestance.jpg', content_type: 'image/jpeg')
    warrior_skills << defensive_stance

    skullsplitter = Skill.create(
      name: "Skullsplitter",
      description: "Your critical strikes now deal 180% increased damage.",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'skullsplitter.jpg')
    skullsplitter.skill_image.attach(io: File.open(image_path), filename: 'skullsplitter.jpg', content_type: 'image/jpeg')
    warrior_skills << skullsplitter

    gushing_wounds = Skill.create(
      name: "Gushing wounds",
      description: "When you deal damage to your opponent for the first time, increase its damage taken by 5% for the rest of the fight.",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'gushingwounds.jpg')
    gushing_wounds.skill_image.attach(io: File.open(image_path), filename: 'gushingwounds.jpg', content_type: 'image/jpeg')
    warrior_skills << gushing_wounds

    grip_of_legends = Skill.create(
      name: "Grip of Legends",
      description: "You can now dual-wield two-handed weapons.",
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'gripoflegends.jpg')
    grip_of_legends.skill_image.attach(io: File.open(image_path), filename: 'gripoflegends.jpg', content_type: 'image/jpeg')
    warrior_skills << grip_of_legends

    gladitator = Skill.create(
      name: "Gladiator",
      description: "Dual wielding one-handed weapons grants you 12% increased Attack and 2% critical strike chance.",
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'gladiator.jpg')
    gladitator.skill_image.attach(io: File.open(image_path), filename: 'gladiator.jpg', content_type: 'image/jpeg')
    warrior_skills << gladitator

    berserk = Skill.create(
      name: "Berserk",
      description: "When reaching 50% Health, Attack starts increasing by 1% for every 1% missing Health.",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'berserk.jpg')
    berserk.skill_image.attach(io: File.open(image_path), filename: 'berserk.jpg', content_type: 'image/jpeg')
    warrior_skills << berserk

    last_stand = Skill.create(
      name: "Last stand",
      description: "When reaching 50% Health, your Armor and Magic resistance are increased by 30% and you recover 10% of your health.",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'laststand.jpg')
    last_stand.skill_image.attach(io: File.open(image_path), filename: 'laststand.jpg', content_type: 'image/jpeg')
    warrior_skills << last_stand
  end
end