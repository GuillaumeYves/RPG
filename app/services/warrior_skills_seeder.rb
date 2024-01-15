class WarriorSkillsSeeder
  attr_reader :character, :warrior_skills

  def initialize(character)
    @character = character
    @warrior_skills = []
  end

  def seed_skills
    warrior_class = "warrior"

    berserk = Skill.create(
      name: "Berserk",
      description: "When reaching 50% Health, Attack starts increasing by 1% for every 1% missing Health.",
      row: 1,
      level_requirement: 1,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'berserk.jpg')
    berserk.skill_image.attach(io: File.open(image_path), filename: 'berserk.jpg', content_type: 'image/jpeg')
    warrior_skills << berserk

    last_stand = Skill.create(
      name: "Last stand",
      description: "When reaching 50% Health, your Armor and Magic resistance are increased by 30% and you recover 10% of your health.",
      row: 1,
      level_requirement: 1,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'laststand.jpg')
    last_stand.skill_image.attach(io: File.open(image_path), filename: 'laststand.jpg', content_type: 'image/jpeg')
    warrior_skills << last_stand
  end
end