class WarriorSkillsSeeder
  attr_reader :character, :warrior_skills

  def initialize(character)
    @character = character
    @warrior_skills = []
  end

  def seed_skills
    puts "Seeding warrior skills for character ID: #{character.id}"
    # Your logic to seed warrior skills goes here
    warrior_class = "warrior"

    berserk = Skill.create(
      name: "Berserk",
      description: "When reaching 50% Health, Attack starts increasing by 1% for every 1% missing Health.",
      row: 1,
      level_requirement: 20,
      character_class: warrior_class,
      character_id: character.id
    )

    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'berserk.jpg')
    berserk.skill_image.attach(io: File.open(image_path), filename: 'berserk.jpg', content_type: 'image/jpeg')

    # Add the created skill to the array
    warrior_skills << berserk

    puts "Warrior skills seeded for character ID: #{character.id}"
  end
end