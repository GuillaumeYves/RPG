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
      description: "Your Attack increases by 5% each turn.",
      skill_type: "combat",
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
      description: "Your Armor and Magic Resistance are increased by 20% while wielding a Shield.",
      skill_type: "passive",
      row: 1,
      level_requirement: 25,
      character_class: warrior_class,
      character_id: character.id,
      effect: 
        " if self.off_hand.present? && self.off_hand.item_type == 'Shield' 
        self.total_armor *= 1.2;
        self.total_magic_resistance *= 1.2;
        end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'defensivestance.jpg')
    defensive_stance.skill_image.attach(io: File.open(image_path), filename: 'defensivestance.jpg', content_type: 'image/jpeg')
    warrior_skills << defensive_stance

    skullsplitter = Skill.create(
      name: "Skullsplitter",
      description: "Your Attack is increased by 10% and your Critical Strikes deal 30% increased damage while wielding a Two-handed Weapon.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
      effect: " 
      if self.main_hand.present? && self.main_hand.item_type == 'Two-handed Weapon' || self.off_hand.present? && self.off_hand.item_type == 'Two-handed Weapon'
        self.total_critical_strike_damage = (self.critical_strike_damage + 0.3);
        self.total_attack *= 1.1; 
      end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'skullsplitter.jpg')
    skullsplitter.skill_image.attach(io: File.open(image_path), filename: 'skullsplitter.jpg', content_type: 'image/jpeg')
    warrior_skills << skullsplitter

    blood_frenzy = Skill.create(
      name: "Blood Frenzy",
      description: "You gain 5% of your maximum Health as additional Attack but you cannot deal Critical Strikes.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
      effect: 
      " self.total_critical_strike_chance = 0
        self.total_critical_strike_damage = 0; 
        self.total_attack = (self.attack + (self.max_health * 0.05)); "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'bloodfrenzy.jpg')
    blood_frenzy.skill_image.attach(io: File.open(image_path), filename: 'bloodfrenzy.jpg', content_type: 'image/jpeg')
    warrior_skills << blood_frenzy

    titans_offspring = Skill.create(
      name: "Titans offspring",
      description: "You can now dual wield Two-handed Weapons.",
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'titansoffspring.jpg')
    titans_offspring.skill_image.attach(io: File.open(image_path), filename: 'titansoffspring.jpg', content_type: 'image/jpeg')
    warrior_skills << titans_offspring

    fury_incarnate = Skill.create(
      name: "Fury Incarnate",
      description: "Your Attack is doubled and your Strength increases even further your Attack.",
      skill_type: "passive",      
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
      effect: 
      " self.total_attack *= 2;  "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'furyincarnate.jpg')
    fury_incarnate.skill_image.attach(io: File.open(image_path), filename: 'furyincarnate.jpg', content_type: 'image/jpeg')
    warrior_skills << fury_incarnate

    berserk = Skill.create(
      name: "Berserk",
      description: "When reaching 50% Health, your Attack is increased by 50%.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
      effect:
        " if self.health <= self.max_health / 2
            puts '##### Berserk ##### '
            self.buffed_attack = self.total_attack * 0.5
          end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'berserk.jpg')
    berserk.skill_image.attach(io: File.open(image_path), filename: 'berserk.jpg', content_type: 'image/jpeg')
    warrior_skills << berserk

    last_stand = Skill.create(
      name: "Last Stand",
      description: "When reaching 50% Health, your Armor and Magic Resistance are increased by 50%.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
      effect: 
          " if self.health <= self.max_health / 2
            puts '##### Last Stand ##### '
            self.buffed_armor = self.total_armor + (self.total_armor * 0.5);
            self.buffed_magic_resistance = self.total_magic_resistance + (self.total_magic_resistance * 0.5);
          end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'laststand.jpg')
    last_stand.skill_image.attach(io: File.open(image_path), filename: 'laststand.jpg', content_type: 'image/jpeg')
    warrior_skills << last_stand
  end
end