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
      description: "After attacking your Attack increases by 5%.",
      skill_type: "combat",
      row: 1,
      level_requirement: 25,
      character_class: warrior_class,
      character_id: character.id,
      effect: " self.buffed_min_attack += (self.total_min_attack * 0.05);
              self.buffed_max_attack += (self.total_max_attack * 0.05);  "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'rage.jpg')
    rage.skill_image.attach(io: File.open(image_path), filename: 'rage.jpg', content_type: 'image/jpeg')
    warrior_skills << rage

    defensive_stance = Skill.create(
      name: "Juggernaut",
      skill_type: "passive",
      description: "You unlock the true potential of your Strength and it now also increases your Health.",
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
      description: "When dealing a Critical Strike with an attack you inflict 10% of your opponent's Maximum Health as additional physical damage.",
      skill_type: "trigger",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'skullsplitter.jpg')
    skullsplitter.skill_image.attach(io: File.open(image_path), filename: 'skullsplitter.jpg', content_type: 'image/jpeg')
    warrior_skills << skullsplitter

    deep_wounds = Skill.create(
      name: "Deep Wounds",
      description: "After attacking cause the opponent to suffer physical damage equivalent to the initial attack damage applied as bleeding over 3 turns.
      Only one instance of Deep Wounds can be active on the opponent at a time.",
      skill_type: "trigger",
      row: 2,
      level_requirement: 50,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'deepwounds.jpg')
    deep_wounds.skill_image.attach(io: File.open(image_path), filename: 'deepwounds.jpg', content_type: 'image/jpeg')
    warrior_skills << deep_wounds

    forged_in_battle = Skill.create(
      name: "Forged in Battle",
      skill_type: "passive",
      description: "You can dual wield Two-handed Weapons but your attacks now have a 20% chance to miss. Reduce your Attack by 30%.",
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
      effect:
      " self.total_min_attack *= 0.7;
        self.total_max_attack *= 0.7;"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'forgedinbattle.jpg')
    forged_in_battle.skill_image.attach(io: File.open(image_path), filename: 'forgedinbattle.jpg', content_type: 'image/jpeg')
    warrior_skills << forged_in_battle

    undeniable = Skill.create(
      name: "Undeniable",
      description: "Your attacks cannot be evaded.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: warrior_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'undeniable.jpg')
    undeniable.skill_image.attach(io: File.open(image_path), filename: 'undeniable.jpg', content_type: 'image/jpeg')
    warrior_skills << undeniable

    berserk = Skill.create(
      name: "Berserk",
      description: "When you reach 20% Health your Attack is increased by 200%.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
      effect: " if (self.total_health <= (0.2 * self.total_max_health))
            self.buffed_min_attack = (self.total_min_attack * 2).round;
            self.buffed_max_attack = (self.total_max_attack * 2).round;
          end  "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'berserk.jpg')
    berserk.skill_image.attach(io: File.open(image_path), filename: 'berserk.jpg', content_type: 'image/jpeg')
    warrior_skills << berserk

    unbridled_ferocity = Skill.create(
      name: "Unbridled Ferocity",
      description: "Your Attack is increased by 80% but you can no longer evade or ignore pain.",
      skill_type: "passive",
      row: 4,
      level_requirement: 100,
      character_class: warrior_class,
      character_id: character.id,
      effect:
          " self.total_min_attack *= 1.8;
            self.total_max_attack *= 1.8;"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'warrior_skills', 'unbridledferocity.jpg')
    unbridled_ferocity.skill_image.attach(io: File.open(image_path), filename: 'unbridledferocity.jpg', content_type: 'image/jpeg')
    warrior_skills << unbridled_ferocity
  end
end
