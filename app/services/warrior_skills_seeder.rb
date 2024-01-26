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
      description: "After taking damage, your Attack increases by 5%.",
      skill_type: "trigger",
      row: 1,
      level_requirement: 25,
      character_class: warrior_class,
      character_id: character.id,
      effect: " puts '##### Rage ##### '; self.buffed_attack += (self.total_attack * 0.05); "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'rage.jpg')
    rage.skill_image.attach(io: File.open(image_path), filename: 'rage.jpg', content_type: 'image/jpeg')
    warrior_skills << rage

    defensive_stance = Skill.create(
      name: "Defensive Stance",
      description: "Your Armor and Magic resistance are increased by 20%, but your Attack and Spellpower are reduced by 5%.",
      skill_type: "passive",
      row: 1,
      level_requirement: 25,
      character_class: warrior_class,
      character_id: character.id,
      effect: 
        " self.total_armor *= 1.2;
        self.total_magic_resistance *= 1.2;
        self.total_spellpower *= 0.95;
        self.total_attack *= 0.95; "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'defensivestance.jpg')
    defensive_stance.skill_image.attach(io: File.open(image_path), filename: 'defensivestance.jpg', content_type: 'image/jpeg')
    warrior_skills << defensive_stance

    skullsplitter = Skill.create(
      name: "Skullsplitter",
      description: "Your Critical Strikes now deal 30% increased damage.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
      effect: " self.total_critical_strike_damage = (self.critical_strike_damage + 0.3); "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'skullsplitter.jpg')
    skullsplitter.skill_image.attach(io: File.open(image_path), filename: 'skullsplitter.jpg', content_type: 'image/jpeg')
    warrior_skills << skullsplitter

    blood_frenzy = Skill.create(
      name: "Blood Frenzy",
      description: "You gain 2% of your maximum Health as additional Attack, but your Critical Strikes now deal no additional damage.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
      effect: 
      " self.total_critical_strike_damage = 0; 
        self.total_attack = (self.attack + (self.max_health * 0.02)); "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'bloodfrenzy.jpg')
    blood_frenzy.skill_image.attach(io: File.open(image_path), filename: 'bloodfrenzy.jpg', content_type: 'image/jpeg')
    warrior_skills << blood_frenzy

    titans_offspring = Skill.create(
      name: "Titans offspring",
      description: "You can now dual-wield two-handed weapons.",
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'titansoffspring.jpg')
    titans_offspring.skill_image.attach(io: File.open(image_path), filename: 'titansoffspring.jpg', content_type: 'image/jpeg')
    warrior_skills << titans_offspring

    gladitator = Skill.create(
      name: "Gladiator",
      description: "You can now dual wield one-handed weapons.",
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
      description: "When reaching 50% Health, Attack is increased by 1% for every 1% missing Health.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
      effect:
        " if self.health <= self.max_health / 2
          missing_health_percentage = ((self.max_health - self.health) / self.max_health) * 100
            puts '##### Berserk ##### '
            self.buffed_attack += missing_health_percentage * 1
          end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'berserk.jpg')
    berserk.skill_image.attach(io: File.open(image_path), filename: 'berserk.jpg', content_type: 'image/jpeg')
    warrior_skills << berserk

    last_stand = Skill.create(
      name: "Last Stand",
      description: "When reaching 50% Health, your Armor and Magic resistance are increased by 40%.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
      effect: 
          " if self.health <= self.max_health / 2
            puts '##### Last Stand ##### '
            self.buffed_armor = self.total_armor + (self.total_armor * 0.4);
            self.buffed_magic_resistance = self.total_magic_resistance + (self.total_magic_resistance * 0.4);
          end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'laststand.jpg')
    last_stand.skill_image.attach(io: File.open(image_path), filename: 'laststand.jpg', content_type: 'image/jpeg')
    warrior_skills << last_stand
  end
end