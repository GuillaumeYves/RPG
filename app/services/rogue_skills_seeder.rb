class RogueSkillsSeeder
  attr_reader :character, :rogue_skills

  def initialize(character)
    @character = character
    @rogue_skills = []
  end

  def seed_skills
    rogue_class = "rogue"

    poisoned_blade = Skill.create(
      name: "Poisoned Blade",
      description: "After dealing damage, your opponent takes 10% of your Attack as additional Magic damage.",
      skill_type: "trigger",
      row: 1,
      level_requirement: 25,
      character_class: rogue_class,
      character_id: character.id,
      effect: "
        damage = (self.total_attack - opponent.total_magic_resistance) * 0.1
        if opponent.took_damage == true
        opponent.health -= damage
        end
        "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'poisonedblade.jpg')
    poisoned_blade.skill_image.attach(io: File.open(image_path), filename: 'poisonedblade.jpg', content_type: 'image/jpeg')
    rogue_skills << poisoned_blade

    sharpened_blade = Skill.create(
      name: "Sharpened Blade",
      description: "After dealing damage, your opponent takes 10% of your Attack as additional Physical damage.",
      skill_type: "trigger",
      row: 1,
      level_requirement: 25,
      character_class: rogue_class,
      character_id: character.id,
      effect: "
        damage = (self.total_attack - opponent.total_armor) * 0.1
        if opponent.took_damage == true
            opponent.health -= damage
        end
        "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'sharpenedblade.jpg')
    sharpened_blade.skill_image.attach(io: File.open(image_path), filename: 'sharpenedblade.jpg', content_type: 'image/jpeg')
    rogue_skills << sharpened_blade

    hidden_blade = Skill.create(
      name: "Hidden blade",
      description: "After each turn, your Attack is increased by 2% against an opponent with higher Health than yours.",
      skill_type: "combat",
      row: 2,
      level_requirement: 50,
      character_class: rogue_class,
      character_id: character.id,
      effect: "
      if @opponent.max_health > self.max_health
        self.buffed_attack += (self.total_attack * 0.02)
      end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'hiddenblade.jpg')
    hidden_blade.skill_image.attach(io: File.open(image_path), filename: 'hiddenblade.jpg', content_type: 'image/jpeg')
    rogue_skills << hidden_blade

    prey_on_the_weak = Skill.create(
      name: "Prey on the Weak",
      description: "After each turn, your Attack is increased by 4% against an opponent with lower Health than yours.",
      skill_type: "combat",
      row: 2,
      level_requirement: 50,
      character_class: rogue_class,
      character_id: character.id,
      effect: "
      if @opponent.max_health < self.max_health
        self.buffed_attack += (self.total_attack * 0.04)
      end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'preyontheweak.jpg')
    prey_on_the_weak.skill_image.attach(io: File.open(image_path), filename: 'preyontheweak.jpg', content_type: 'image/jpeg')
    rogue_skills << prey_on_the_weak

    swift_movements = Skill.create(
      name: "Swift movements",
      description: "You gain increased Attack based on your Agility instead of your Strength.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: rogue_class,
      character_id: character.id,
      effect: " self.total_attack = self.attack + self.agility_bonus "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'swiftmovements.jpg')
    swift_movements.skill_image.attach(io: File.open(image_path), filename: 'swiftmovements.jpg', content_type: 'image/jpeg')
    rogue_skills << swift_movements

    from_the_shadows = Skill.create(
      name: "From the Shadows",
      description: "When you deal damage to your opponent, inflict 5% of your Attack as additional True damage.",
      skill_type: "trigger",
      row: 3,
      level_requirement: 75,
      character_class: rogue_class,
      character_id: character.id,
      effect: "
        damage = self.total_attack * 0.1
        if opponent.took_damage == true
            opponent.health -= damage
        end
        "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'fromtheshadows.jpg')
    from_the_shadows.skill_image.attach(io: File.open(image_path), filename: 'fromtheshadows.jpg', content_type: 'image/jpeg')
    rogue_skills << from_the_shadows

    executionner = Skill.create(
      name: "Executionner",
      description: "If your opponent has 30% or less Health, increase your Attack by 30% and your Critical Strike Damage by 50%.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: rogue_class,
      character_id: character.id,
      effect:
          " health_percentage = opponent.health / opponent.max_health
          if health_percentage <= 0.5
            self.buffed_attack += (self.total_attack * 0.3);
            self.buffed_critical_strike_damage += 0.3;
          end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'executionner.jpg')
    executionner.skill_image.attach(io: File.open(image_path), filename: 'executionner.jpg', content_type: 'image/jpeg')
    rogue_skills << executionner

    death_mark = Skill.create(
      name: "Death Mark",
      description: "After attacking, your Attack increases by 20%.",
      skill_type: "combat",
      row: 4,
      level_requirement: 100,
      character_class: rogue_class,
      character_id: character.id,
      effect: " self.buffed_attack += (self.total_attack * 1.2); "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'deathmark.jpg')
    death_mark.skill_image.attach(io: File.open(image_path), filename: 'deathmark.jpg', content_type: 'image/jpeg')
    rogue_skills << death_mark
  end
end