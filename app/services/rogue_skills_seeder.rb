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
      skill_type: "combat",
      description: "You have a 30% chance to poison your opponent after attacking, dealing 50% of your Attack as magic damage.",
      row: 1,
      level_requirement: 25,
      character_class: rogue_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'poisonedblade.jpg')
    poisoned_blade.skill_image.attach(io: File.open(image_path), filename: 'poisonedblade.jpg', content_type: 'image/jpeg')
    rogue_skills << poisoned_blade

    sharpened_blade = Skill.create(
      name: "Sharpened Blade",
      skill_type: "combat",
      description: "You have a 30% chance to maim your opponent after attacking, dealing 50% of your Attack as physical damage.",
      row: 1,
      level_requirement: 25,
      character_class: rogue_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'sharpenedblade.jpg')
    sharpened_blade.skill_image.attach(io: File.open(image_path), filename: 'sharpenedblade.jpg', content_type: 'image/jpeg')
    rogue_skills << sharpened_blade

    hidden_blade = Skill.create(
      name: "Hidden Blade",
      description: "While dual wielding Daggers, your Critical Strike Chance by 5% and your Critical Strikes deal 50% increased damage.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: rogue_class,
      character_id: character.id,
      effect: "
      if self.main_hand.present? && self.off_hand.present? && self.main_hand.item_class == 'Dagger' && self.off_hand.item_class == 'Dagger'
        self.total_critical_strike_chance += 5.0;
        self.total_critical_strike_damage += 0.50;
      end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'hiddenblade.jpg')
    hidden_blade.skill_image.attach(io: File.open(image_path), filename: 'hiddenblade.jpg', content_type: 'image/jpeg')
    rogue_skills << hidden_blade

    menacing_presence = Skill.create(
      name: "Menacing Presence",
      description: "Your Health is increased by 50% and your Attack is increased by 20%.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: rogue_class,
      character_id: character.id,
      effect: " self.total_health *= 1.5;
        self.total_max_health *= 1.5;
        self.total_attack *= 1.2; "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'menacingpresence.jpg')
    menacing_presence.skill_image.attach(io: File.open(image_path), filename: 'menacingpresence.jpg', content_type: 'image/jpeg')
    rogue_skills << menacing_presence

    swift_movements = Skill.create(
      name: "Swift Movements",
      skill_type: "passive",
      description: "You gain increased Attack based on your Agility instead of your Strength.
      You have an increasing chance of performing an additional attack, for 50% damage, the more Agility you have.",
      row: 3,
      level_requirement: 75,
      character_class: rogue_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'swiftmovements.jpg')
    swift_movements.skill_image.attach(io: File.open(image_path), filename: 'swiftmovements.jpg', content_type: 'image/jpeg')
    rogue_skills << swift_movements

    from_the_shadows = Skill.create(
      name: "From the Shadows",
      description: "Your Critical Strikes deal 25% of their damage as additional true damage.",
      skill_type: "trigger",
      row: 3,
      level_requirement: 75,
      character_class: rogue_class,
      character_id: character.id,
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'fromtheshadows.jpg')
    from_the_shadows.skill_image.attach(io: File.open(image_path), filename: 'fromtheshadows.jpg', content_type: 'image/jpeg')
    rogue_skills << from_the_shadows

    unnatural_instinct = Skill.create(
      name: "Unnatural Instinct",
      description: "When you reach 50% Health, your Attack is increased by 30% and your Critical Strike Damage by 100%.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: rogue_class,
      character_id: character.id,
      effect: " if self.total_health <= self.total_max_health / 2
            self.buffed_critical_strike_damage += 1.00
            self.buffed_attack = (self.total_attack * 0.3) ;
          end  "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'unnaturalinstinct.jpg')
    unnatural_instinct.skill_image.attach(io: File.open(image_path), filename: 'unnaturalinstinct.jpg', content_type: 'image/jpeg')
    rogue_skills << unnatural_instinct

    death_mark = Skill.create(
      name: "Death Mark",
      description: "After each attack, your Critical Strike Damage is increased by 20% and your Critical Strike Chance by 2%.",
      skill_type: "combat",
      row: 4,
      level_requirement: 100,
      character_class: rogue_class,
      character_id: character.id,
      effect: " self.buffed_critical_strike_damage += 0.20;
                self.buffed_critical_strike_chance += 2.0;"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'deathmark.jpg')
    death_mark.skill_image.attach(io: File.open(image_path), filename: 'deathmark.jpg', content_type: 'image/jpeg')
    rogue_skills << death_mark
  end
end
