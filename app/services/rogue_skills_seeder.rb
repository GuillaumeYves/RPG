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
      description: "After each attack, your Attack increases by 2% of your Spellpower.",
      skill_type: "combat",
      row: 1,
      level_requirement: 25,
      character_class: rogue_class,
      character_id: character.id,
      effect: " puts '##### Poisoned Blade ##### '; self.buffed_attack += (self.total_spellpower * 0.02); "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'poisonedblade.jpg')
    poisoned_blade.skill_image.attach(io: File.open(image_path), filename: 'poisonedblade.jpg', content_type: 'image/jpeg')
    rogue_skills << poisoned_blade

    sharpened_blade = Skill.create(
      name: "Sharpened Blade",
      description: "After each attack, your Attack increases by 1% of your Attack.",
      skill_type: "combat",
      row: 1,
      level_requirement: 25,
      character_class: rogue_class,
      character_id: character.id,
      effect: " puts '##### Sharpened Blade ##### '; self.buffed_attack += (self.total_attack * 0.01); "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'sharpenedblade.jpg')
    sharpened_blade.skill_image.attach(io: File.open(image_path), filename: 'sharpenedblade.jpg', content_type: 'image/jpeg')
    rogue_skills << sharpened_blade

    hidden_blade = Skill.create(
      name: "Hidden Blade",
      description: "After each attack, your Critical Strike Chance increases by 0.5%.",
      skill_type: "combat",
      row: 2,
      level_requirement: 50,
      character_class: rogue_class,
      character_id: character.id,
      effect: " puts '##### Hidden Blade ##### '; self.buffed_critical_strike_chance += 0.5 ; "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'hiddenblade.jpg')
    hidden_blade.skill_image.attach(io: File.open(image_path), filename: 'hiddenblade.jpg', content_type: 'image/jpeg')
    rogue_skills << hidden_blade

    menacing_presence = Skill.create(
      name: "Menacing Presence",
      description: "Your Critical Strike Chance is reduced by 10%, but your Critical Strikes now deal 30% increased damage.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: rogue_class,
      character_id: character.id,
      effect: " self.total_critical_strike_chance *= 0.90 ; 
                self.total_critical_strike_damage = (self.critical_strike_damage + 0.30) ;"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'menacingpresence.jpg')
    menacing_presence.skill_image.attach(io: File.open(image_path), filename: 'menacingpresence.jpg', content_type: 'image/jpeg')
    rogue_skills << menacing_presence

    swift_movements = Skill.create(
      name: "Swift Movements",
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
      description: " Your Health is increased by 20% and your Armor and Magic resistance are increased by 10%.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: rogue_class,
      character_id: character.id,
      effect: " self.max_health *= 1.2;
                self.health *= 1.2;
                self.total_armor *= 1.1;
                self.total_magic_resistance *= 1.1;"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'fromtheshadows.jpg')
    from_the_shadows.skill_image.attach(io: File.open(image_path), filename: 'fromtheshadows.jpg', content_type: 'image/jpeg')
    rogue_skills << from_the_shadows

    unnatural_instinct = Skill.create(
      name: "Unnatural Instinct",
      description: "When you reach 50% Health, your Attack is increased by 30% and your Critical Strikes deal 30% increased damage.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: rogue_class,
      character_id: character.id,
      effect: " if self.health <= self.max_health / 2
            puts '##### Unnatural Instinct ##### '
            self.buffed_attack = self.total_attack + (self.total_attack * 0.3) ;
            self.buffed_critical_strike_damage = 0.3;
          end  "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'unnaturalinstinct.jpg')
    unnatural_instinct.skill_image.attach(io: File.open(image_path), filename: 'unnaturalinstinct.jpg', content_type: 'image/jpeg')
    rogue_skills << unnatural_instinct

    death_mark = Skill.create(
      name: "Death Mark",
      description: "After each attack, your Attack increases by 10% and your Critical Strike Chance by 1%.",
      skill_type: "combat",
      row: 4,
      level_requirement: 100,
      character_class: rogue_class,
      character_id: character.id,
      effect: "  puts '##### Death Mark ##### '; self.buffed_attack += (self.total_attack * 0.1); 
                self.buffed_critical_strike_chance += 1.0;"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'deathmark.jpg')
    death_mark.skill_image.attach(io: File.open(image_path), filename: 'deathmark.jpg', content_type: 'image/jpeg')
    rogue_skills << death_mark
  end
end