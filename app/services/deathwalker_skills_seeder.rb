class DeathwalkerSkillsSeeder
  attr_reader :character, :deathwalker_skills

  def initialize(character)
    @character = character
    @deathwalker_skills = []
  end

  def seed_skills
    deathwalker_class = "deathwalker"

    bloodforging = Skill.create(
      name: "Bloodforging",
      description: "You gain 2% of your maximum Health as Necrosurge.",
      skill_type: "passive",
      row: 1,
      level_requirement: 25,
      character_class: deathwalker_class,
      character_id: character.id,
      effect: " self.total_necrosurge = self.total_necrosurge + (self.total_max_health * 0.02)"
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'deathwalker_skills', 'bloodforging.jpg')
    bloodforging.skill_image.attach(io: File.open(image_path), filename: 'bloodforging.jpg', content_type: 'image/jpeg')
    deathwalker_skills << bloodforging

    lifetap = Skill.create(
      name: "Lifetap",
      description: "At the end of each turn, you sacrifice 1% of your maximum Health to gain double of that amount as Necrosurge.",
      skill_type: "combat",
      row: 1,
      level_requirement: 25,
      character_class: deathwalker_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'deathwalker_skills', 'lifetap.jpg')
    lifetap.skill_image.attach(io: File.open(image_path), filename: 'lifetap.jpg', content_type: 'image/jpeg')
    deathwalker_skills << lifetap

    ephemeral_rebirth = Skill.create(
      name: "Ephemeral Rebirth",
      description: "During combat if your Health drops to 0, you are reborn with 100% of your Health but you start losing 10% of your maximum Health at the end of each turn.
      This can only happen once per combat.",
      skill_type: "trigger",
      row: 2,
      level_requirement: 50,
      character_class: deathwalker_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'deathwalker_skills', 'ephemeralrebirth.jpg')
    ephemeral_rebirth.skill_image.attach(io: File.open(image_path), filename: 'ephemeralrebirth.jpg', content_type: 'image/jpeg')
    deathwalker_skills << ephemeral_rebirth

    blood_monarch = Skill.create(
      name: "Blood Monarch",
      description: "Your Health is increased by 66% but you no longer have Armor and Magic Resistance.",
      skill_type: "passive",
      row: 2,
      level_requirement: 50,
      character_class: deathwalker_class,
      character_id: character.id,
      effect: "self.total_max_health *= 1.66;
              self.total_health *= 1.66;
              self.total_armor = 0;
              self.total_magic_resistance = 0; "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'deathwalker_skills', 'bloodmonarch.jpg')
    blood_monarch.skill_image.attach(io: File.open(image_path), filename: 'bloodmonarch.jpg', content_type: 'image/jpeg')
    deathwalker_skills << blood_monarch

    path_of_the_dead = Skill.create(
      name: "Path of the Dead",
      description: "Increase your maximum Health by 33%. When dealing a Critical Strike, you recover 6% of that damage as Health.",
      skill_type: "passive",
      row: 3,
      level_requirement: 75,
      character_class: deathwalker_class,
      character_id: character.id,
      effect: "
              self.total_max_health *= 1.33;
              self.total_health *= 1.33;"
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'deathwalker_skills', 'pathofthedead.jpg')
    path_of_the_dead.skill_image.attach(io: File.open(image_path), filename: 'pathofthedead.jpg', content_type: 'image/jpeg')
    deathwalker_skills << path_of_the_dead

    crimson_torrent = Skill.create(
      name: "Crimson Torrent",
      description: "At the end of each turn you deal 3% of your maximum Health as shadow damage.",
      skill_type: "combat",
      row: 3,
      level_requirement: 75,
      character_class: deathwalker_class,
      character_id: character.id,
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'deathwalker_skills', 'crimsontorrent.jpg')
    crimson_torrent.skill_image.attach(io: File.open(image_path), filename: 'crimsontorrent.jpg', content_type: 'image/jpeg')
    deathwalker_skills << crimson_torrent

    cadaverous_pact = Skill.create(
      name: "Cadaverous Pact",
      description: "Your Necrosurge is increased by 66%.",
      skill_type: "passive",
      row: 4,
      level_requirement: 100,
      character_class: deathwalker_class,
      character_id: character.id,
      effect: "
              self.total_necrosurge *= 1.66; "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'deathwalker_skills', 'cadaverouspact.jpg')
    cadaverous_pact.skill_image.attach(io: File.open(image_path), filename: 'cadaverouspact.jpg', content_type: 'image/jpeg')
    deathwalker_skills << cadaverous_pact

    sanguine_eclipse = Skill.create(
      name: "Sanguine Eclipse",
      description: "When you reach 30% Health, your Necrosurge is doubled.",
      skill_type: "trigger",
      row: 4,
      level_requirement: 100,
      character_class: deathwalker_class,
      character_id: character.id,
      effect: "
              if (self.total_health <= (0.3 * self.total_max_health))
                self.buffed_necrosurge = self.total_necrosurge
              end "
      )
    image_path = Rails.root.join('app', 'assets', 'images', 'deathwalker_skills', 'sanguineeclipse.jpg')
    sanguine_eclipse.skill_image.attach(io: File.open(image_path), filename: 'sanguineeclipse.jpg', content_type: 'image/jpeg')
    deathwalker_skills << sanguine_eclipse
  end
end
