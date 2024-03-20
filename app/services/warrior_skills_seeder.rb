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
      effect: " self.buffed_attack += (self.total_attack * 0.05); "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'rage.jpg')
    rage.skill_image.attach(io: File.open(image_path), filename: 'rage.jpg', content_type: 'image/jpeg')
    warrior_skills << rage

    defensive_stance = Skill.create(
      name: "Juggernaut",
      skill_type: "passive",
      description: "You unlock the true potential of your Strength and it also increases your Health.",
      row: 1,
      level_requirement: 25,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'juggernaut.jpg')
    defensive_stance.skill_image.attach(io: File.open(image_path), filename: 'juggernaut.jpg', content_type: 'image/jpeg')
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
        self.total_critical_strike_damage = (self.critical_strike_damage + 0.30);
        self.total_attack *= 1.1;
      end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'skullsplitter.jpg')
    skullsplitter.skill_image.attach(io: File.open(image_path), filename: 'skullsplitter.jpg', content_type: 'image/jpeg')
    warrior_skills << skullsplitter

    blood_frenzy = Skill.create(
      name: "Blood Frenzy",
      description: "You recover 8% of the damage you deal as Health.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'bloodfrenzy.jpg')
    blood_frenzy.skill_image.attach(io: File.open(image_path), filename: 'bloodfrenzy.jpg', content_type: 'image/jpeg')
    warrior_skills << blood_frenzy

    forged_in_battle = Skill.create(
      name: "Forged in Battle",
      skill_type: "passive",
      description: "You can dual wield Two-handed Weapons but your attacks now have a 10% chance to miss.",
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'forgedinbattle.jpg')
    forged_in_battle.skill_image.attach(io: File.open(image_path), filename: 'forgedinbattle.jpg', content_type: 'image/jpeg')
    warrior_skills << forged_in_battle

    undeniable = Skill.create(
      name: "Undeniable",
      description: "While wielding a Two-handed Weapon, your Attack is increased by 50% but you can no longer Ignore Pain or Evade.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
      effect:
      " if self.main_hand.present? && self.main_hand.item_type == 'Two-handed Weapon'
          self.total_attack *= 1.5;
        end"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'undeniable.jpg')
    undeniable.skill_image.attach(io: File.open(image_path), filename: 'undeniable.jpg', content_type: 'image/jpeg')
    warrior_skills << undeniable

    berserk = Skill.create(
      name: "Berserk",
      description: "When you reach 30% Health, your Attack is increased by 50%.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
      effect: " if (self.total_health <= (0.3 * self.total_max_health))
            self.buffed_attack = (self.total_attack * 0.5) ;
          end  "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'berserk.jpg')
    berserk.skill_image.attach(io: File.open(image_path), filename: 'berserk.jpg', content_type: 'image/jpeg')
    warrior_skills << berserk

    unbridled_ferocity = Skill.create(
      name: "Unbridled Ferocity",
      description: "Your Attack is increased by 30% but your Armor and Magic Resistance are reduced by 50%.",
      skill_type: "passive",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
      effect:
          " self.total_attack *= 1.3;
            self.total_armor *= 0.5;
            self.total_magic_resistance *= 0.5; "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'unbridledferocity.jpg')
    unbridled_ferocity.skill_image.attach(io: File.open(image_path), filename: 'unbridledferocity.jpg', content_type: 'image/jpeg')
    warrior_skills << unbridled_ferocity
  end
end
