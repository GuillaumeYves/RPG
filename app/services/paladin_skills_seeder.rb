class PaladinSkillsSeeder
  attr_reader :character, :paladin_skills

  def initialize(character)
    @character = character
    @paladin_skills = []
  end

  def seed_skills
    paladin_class = "paladin"

    piety = Skill.create(
      name: "Piety",
      description: "Your Strength also increases your Armor.",
      row: 1,
      level_requirement: 25,
      character_class: paladin_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'piety.jpg')
    piety.skill_image.attach(io: File.open(image_path), filename: 'piety.jpg', content_type: 'image/jpeg')
    paladin_skills << piety

    judgement = Skill.create(
      name: "Judgement",
      description: "Your Intelligence also increases your Attack.",
      row: 1,
      level_requirement: 25,
      character_class: paladin_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'judgement.jpg')
    judgement.skill_image.attach(io: File.open(image_path), filename: 'judgement.jpg', content_type: 'image/jpeg')
    paladin_skills << judgement

    blessingofkings = Skill.create(
      name: "Blessing of Kings",
      description: "When reaching 30% Health your Armor and Magic Resistance are doubled.",
      skill_type: "trigger",
      row: 2,
      level_requirement: 50,
      character_class: paladin_class,
      character_id: character.id,
      effect:
        " if self.health <= 0.3 * self.max_health
            self.buffed_armor = self.total_armor ;
            self.buffed_magic_resistance = self.total_magic_resistance;
          end "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'blessingofkings.jpg')
    blessingofkings.skill_image.attach(io: File.open(image_path), filename: 'blessingofkings.jpg', content_type: 'image/jpeg')
    paladin_skills << blessingofkings

    surge_of_light = Skill.create(
      name: "Surge of Light",
      description: "After taking damage you recover 10% of your Maximum Health.",
      skill_type: "trigger",
      row: 2,
      level_requirement: 50,
      character_class: paladin_class,
      character_id: character.id,
      effect:
        " self.health += (self.max_health * 0.10)"
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'surgeoflight.jpg')
    surge_of_light.skill_image.attach(io: File.open(image_path), filename: 'surgeoflight.jpg', content_type: 'image/jpeg')
    paladin_skills << surge_of_light

    consecrate = Skill.create(
      name: "Smite",
      description: "100% of your Attack is converted into Spellpower. Your Spellpower is increased by 50%.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: paladin_class,
      character_id: character.id,
      effect:
        " self.total_spellpower += self.total_attack;
          self.total_spellpower *= 1.5;
          self.total_attack = 0 "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'consecrate.jpg')
    consecrate.skill_image.attach(io: File.open(image_path), filename: 'consecrate.jpg', content_type: 'image/jpeg')
    paladin_skills << consecrate

    divine_wrath = Skill.create(
      name: "Condemn",
      description: "100% of your Spellpower is converted into Attack. Your Attack is increased by 50%.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: paladin_class,
      character_id: character.id,
      effect:
        " self.total_attack += self.total_spellpower;
          self.total_attack *= 1.5;
          self.total_spellpower = 0 "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'divinewrath.jpg')
    divine_wrath.skill_image.attach(io: File.open(image_path), filename: 'divinewrath.jpg', content_type: 'image/jpeg')
    paladin_skills << divine_wrath

    aspect_of_justice = Skill.create(
      name: "Divine Strength",
      description: "You can wield a Two-handed Weapon while having a Shield.",
      row: 4,
      level_requirement: 100,
      character_class: paladin_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'aspectofjustice.jpg')
    aspect_of_justice.skill_image.attach(io: File.open(image_path), filename: 'aspectofjustice.jpg', content_type: 'image/jpeg')
    paladin_skills << aspect_of_justice

    retribution = Skill.create(
      name: "Fervor",
      description: "Increase your Attack by 20% if your Attack is superior to your Spellpower. 
                    Increase your Spellpower by 20% if your Spellpower is superior to your Attack.",
      skill_type: "passive",
      row: 4,
      level_requirement: 100,
      character_class: paladin_class,
      character_id: character.id,
      effect:
        " if self.total_attack > self.total_spellpower
            self.total_attack *= 1.2;
          elsif self.total_spellpower > self.total_attack
            self.total_spellpower *= 1.2;
        end "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'retribution.jpg')
    retribution.skill_image.attach(io: File.open(image_path), filename: 'retribution.jpg', content_type: 'image/jpeg')
    paladin_skills << retribution
  end
end