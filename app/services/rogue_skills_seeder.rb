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
      description: "You deal additional True Magic damage equal to 10% of your Spellpower.",
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
      description: "You deal additional True Physical damage equal to 2% of your Attack.",
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
      description: "Dual wielding Daggers increases your Critical Strike Chance by 5% and your Critical Strikes deal 50% increased damage.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: rogue_class,
      character_id: character.id,
      effect: " 
      if self.main_hand.present? && self.off_hand.present? && self.main_hand.item_class == 'Dagger' && self.off_hand.item_class == 'Dagger'
        self.total_critical_strike_chance += 5.0;
        self.total_critical_strike_damage += 0.5;
      end "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'hiddenblade.jpg')
    hidden_blade.skill_image.attach(io: File.open(image_path), filename: 'hiddenblade.jpg', content_type: 'image/jpeg')
    rogue_skills << hidden_blade

    menacing_presence = Skill.create(
      name: "Menacing Presence",
      description: "If you have more Health than Attack, your Attack is increased by 40% but your Armor and Magic Resistance are reduced by 20%.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: rogue_class,
      character_id: character.id,
      effect: "
      if self.max_health > self.total_attack 
        self.total_attack *= 1.4; 
        self.total_armor *= 0.8; 
        self.total_magic_resistance *= 0.8; 
      end"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'menacingpresence.jpg')
    menacing_presence.skill_image.attach(io: File.open(image_path), filename: 'menacingpresence.jpg', content_type: 'image/jpeg')
    rogue_skills << menacing_presence

    swift_movements = Skill.create(
      name: "Swift Movements",
      description: "You gain increased Attack based on your Agility instead of your Strength.",
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
      description: " You gain increased Attack based on 80% or your strength and 80% of your Intelligence instead of your Strength.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: rogue_class,
      character_id: character.id,
      effect: " self.total_attack = self.attack + ((self.strength_bonus * 0.8) + (self.intelligence_bonus * 0.8)) "
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
            self.buffed_critical_strike_damage += 0.30
            self.buffed_attack = (self.total_attack * 0.3) ;
          end  "
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'unnaturalinstinct.jpg')
    unnatural_instinct.skill_image.attach(io: File.open(image_path), filename: 'unnaturalinstinct.jpg', content_type: 'image/jpeg')
    rogue_skills << unnatural_instinct

    death_mark = Skill.create(
      name: "Death Mark",
      description: "After each attack, your Attack increases by 1% and your Critical Strike Chance by 1%.",
      skill_type: "combat",
      row: 4,
      level_requirement: 100,
      character_class: rogue_class,
      character_id: character.id,
      effect: "  puts '##### Death Mark ##### '; self.buffed_attack += (self.total_attack * 0.01); 
                self.buffed_critical_strike_chance += 1.0;"
    )
    image_path = Rails.root.join('app', 'assets', 'images', 'rogue_skills', 'deathmark.jpg')
    death_mark.skill_image.attach(io: File.open(image_path), filename: 'deathmark.jpg', content_type: 'image/jpeg')
    rogue_skills << death_mark
  end
end