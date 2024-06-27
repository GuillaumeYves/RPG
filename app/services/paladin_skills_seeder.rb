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
      skill_type: "trigger",
      description: "When reaching 50% Health you recover 20% of your maximum Health. This can only happen once per combat.",
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
      skill_type: "passive",
      description: "Your attacks deal an additional 10% of their initial damage as true damage.",
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
      description: "During your first turn reduce the damage you take from attacks by 15% for 4 turns. This can only happen once per combat.",
      skill_type: "trigger",
      row: 2,
      level_requirement: 50,
      character_class: paladin_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'blessingofkings.jpg')
    blessingofkings.skill_image.attach(io: File.open(image_path), filename: 'blessingofkings.jpg', content_type: 'image/jpeg')
    paladin_skills << blessingofkings

    surge_of_light = Skill.create(
      name: "Surge of Light",
      description: "After taking damage you recover 2% of your maximum Health.",
      skill_type: "trigger",
      row: 2,
      level_requirement: 50,
      character_class: paladin_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'surgeoflight.jpg')
    surge_of_light.skill_image.attach(io: File.open(image_path), filename: 'surgeoflight.jpg', content_type: 'image/jpeg')
    paladin_skills << surge_of_light

    smite = Skill.create(
      name: "Smite",
      description: "100% of your Attack is converted into Spellpower. Increase your Spellpower by 25%.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: paladin_class,
      character_id: character.id,
      effect:
        " self.total_min_spellpower += self.total_min_attack;
          self.total_max_spellpower += self.total_max_attack;
          self.total_min_attack = 0;
          self.total_max_attack = 0;
          self.total_min_spellpower *= 1.25;
          self.total_max_spellpower *= 1.25; "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'smite.jpg')
    smite.skill_image.attach(io: File.open(image_path), filename: 'smite.jpg', content_type: 'image/jpeg')
    paladin_skills << smite

    condemn = Skill.create(
      name: "Condemn",
      description: "100% of your Spellpower is converted into Attack. Increase your Attack by 25%.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: paladin_class,
      character_id: character.id,
      effect:
        " self.total_min_attack += self.total_min_spellpower;
          self.total_max_attack += self.total_max_spellpower;
          self.total_min_spellpower = 0;
          self.total_max_spellpower = 0;
          self.total_min_attack *= 1.25;
          self.total_max_attack *= 1.25; "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'condemn.jpg')
    condemn.skill_image.attach(io: File.open(image_path), filename: 'condemn.jpg', content_type: 'image/jpeg')
    paladin_skills << condemn

    divine_strength = Skill.create(
      name: "Divine Strength",
      skill_type: "passive",
      description: "Your attacks have a 15% chance to deal double damage. Your Damage Reduction now also increases your Attack and Spellpower.",
      row: 4,
      level_requirement: 100,
      character_class: paladin_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'divinestrength.jpg')
    divine_strength.skill_image.attach(io: File.open(image_path), filename: 'divinestrength.jpg', content_type: 'image/jpeg')
    paladin_skills << divine_strength

    fervor = Skill.create(
      name: "Fervor",
      description: "Once per turn you have a 30% chance to attack for 80% of your damage.",
      skill_type: "passive",
      row: 4,
      level_requirement: 100,
      character_class: paladin_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'paladin_skills', 'fervor.jpg')
    fervor.skill_image.attach(io: File.open(image_path), filename: 'fervor.jpg', content_type: 'image/jpeg')
    paladin_skills << fervor
  end
end
