class MageSkillsSeeder
  attr_reader :character, :mage_skills

  def initialize(character)
    @character = character
    @mage_skills = []
  end

  def seed_skills
    mage_class = "mage"

    arcane_protection = Skill.create(
      name: "Arcane Protection",
      description: "Your Magic Resistance is increased by 50%. Your Magic Resistance increases your Armor by 20% of its value.",
      skill_type: "passive",
      row: 1,
      level_requirement: 25,
      character_class: mage_class,
      character_id: character.id,
      effect: " self.total_magic_resistance *= 1.5;
                self.total_armor =  (self.total_armor + (self.total_magic_resistance * 0.2)); "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'mage_skills', 'arcaneprotection.jpg')
    arcane_protection.skill_image.attach(io: File.open(image_path), filename: 'arcaneprotection.jpg', content_type: 'image/jpeg')
    mage_skills << arcane_protection

    book_of_edim = Skill.create(
      name: "Book of Edim",
      skill_type: "passive",
      description: "Your Intelligence also increases your Critical Strike Damage.",
      row: 1,
      level_requirement: 25,
      character_class: mage_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'mage_skills', 'bookofedim.jpg')
    book_of_edim.skill_image.attach(io: File.open(image_path), filename: 'bookofedim.jpg', content_type: 'image/jpeg')
    mage_skills << book_of_edim

    enlighten = Skill.create(
      name: "Enlighten",
      description: "You unlock the true potential of your Intelligence.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: mage_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'mage_skills', 'enlighten.jpg')
    enlighten.skill_image.attach(io: File.open(image_path), filename: 'enlighten.jpg', content_type: 'image/jpeg')
    mage_skills << enlighten

    nullify = Skill.create(
      name: "Nullify",
      skill_type: "trigger",
      description: "During combat if your Health drops to 0, you nullify your death, keeping you at 1 Health. This can only happen once per combat.",
      row: 2,
      level_requirement: 50,
      character_class: mage_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'mage_skills', 'nullify.jpg')
    nullify.skill_image.attach(io: File.open(image_path), filename: 'nullify.jpg', content_type: 'image/jpeg')
    mage_skills << nullify

    runic_empowerment = Skill.create(
      name: "Runic Empowerment",
      description: "After taking damage, your Spellpower is increased by 7%.",
      skill_type: "trigger",
      row: 3,
      level_requirement: 75,
      character_class: mage_class,
      character_id: character.id,
      effect: " self.buffed_min_spellpower += (self.total_min_spellpower * 0.07);
              self.buffed_max_spellpower += (self.total_max_spellpower * 0.07) "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'mage_skills', 'runicempowerment.jpg')
    runic_empowerment.skill_image.attach(io: File.open(image_path), filename: 'runicempowerment.jpg', content_type: 'image/jpeg')
    mage_skills << runic_empowerment

    shared_power = Skill.create(
      name: "Shared Power",
      description: "Your Spellpower is increased by 0.1% for each of your Levels.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: mage_class,
      character_id: character.id,
      effect: "self.total_min_spellpower = self.total_min_spellpower * (self.level * 0.01);
              self.total_max_spellpower = self.total_max_spellpower * (self.level * 0.01);"
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'mage_skills', 'sharedpower.jpg')
    shared_power.skill_image.attach(io: File.open(image_path), filename: 'sharedpower.jpg', content_type: 'image/jpeg')
    mage_skills << shared_power

    wisdom_and_power = Skill.create(
      name: "Wisdom and Power",
      description: "Your Magic Resistance increases your Spellpower by 150% of its value and your Spellpower is increased by 50%.",
      skill_type: "passive",
      row: 4,
      level_requirement: 100,
      character_class: mage_class,
      character_id: character.id,
      effect: " self.total_min_spellpower = (self.total_min_spellpower + (self.total_magic_resistance * 1.5));
              self.total_max_spellpower = (self.total_max_spellpower + (self.total_magic_resistance * 1.5));"
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'mage_skills', 'wisdomandpower.jpg')
    wisdom_and_power.skill_image.attach(io: File.open(image_path), filename: 'wisdomandpower.jpg', content_type: 'image/jpeg')
    mage_skills << wisdom_and_power

    wrath = Skill.create(
      name: "Wrath",
      description: "Your Spellpower increases by 10% and your Critical Strike Chance by 2% each turn.",
      skill_type: "combat",
      row: 4,
      level_requirement: 100,
      character_class: mage_class,
      character_id: character.id,
      effect: " self.buffed_min_spellpower += (self.total_min_spellpower * 0.1);
                self.buffed_max_spellpower += (self.total_max_spellpower * 0.1);
                self.buffed_critical_strike_chance += 2.0; "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'mage_skills', 'wrath.jpg')
    wrath.skill_image.attach(io: File.open(image_path), filename: 'wrath.jpg', content_type: 'image/jpeg')
    mage_skills << wrath
  end
end
