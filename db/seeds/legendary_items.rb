# Method to attach image to item
def attach_image_to_item(item, image_path)
  item.item_image.attach(io: File.open(image_path), filename: File.basename(image_path), content_type: 'image/jpeg')
end
# Create items
[
  {
    name: "Dawnbreaker",
    item_type: "Two-handed Weapon",
    item_class: "Sword",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    min_attack: 192 ,
    max_attack: 320 ,
    strength: 100 ,
    luck: 100 ,
    willpower: 100 ,
    global_damage: 0.10,
    legendary_effect_name: "Dawn's Judgment",
    legendary_effect_description: "When opponent's Health reaches 10% :<br>
    Attempt to execute them for 111% of your damage.",
    description: "Cleave through enemies and bring dawn's justice to the battlefield.",
    image_path: 'app/assets/images/legendary_items/dawnbreaker.jpg'
  },
  {
    name: "Death's Bargain",
    item_type: "Shield",
    item_class: "Great Shield",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    health: 2000 ,
    armor: 150 ,
    magic_resistance: 80 ,
    all_resistances: 50,
    critical_resistance: 200,
    damage_reduction: 0.10 ,
    legendary_effect_name: "Pact of the Undying",
    legendary_effect_description: "When your Health drops to 0 :<br>
    You are reborn with 1 Health.<br>
    This can only happen once per combat.",
    description: "A harbinger of the inevitable rot that awaits all life.",
    image_path: 'app/assets/images/legendary_items/deathsbargain.jpg'
  },
  {
    name: "Eternal Rage",
    item_type: "Head",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 900 ,
    armor: 75 ,
    magic_resistance: 30 ,
    fire_resistance: 100,
    strength: 100 ,
    willpower: 100 ,
    legendary_effect_name: "Wrathful Obsession",
    legendary_effect_description: "After attacking :<br>
    Your Attack is increased by 15%.",
    description: "Anger is a weapon, not just a mere emotion.",
    image_path: 'app/assets/images/legendary_items/eternalrage.jpg'
  },
  {
    name: "Havoc",
    item_type: "Two-handed Weapon",
    item_class: "Bow",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    min_attack: 184 ,
    max_attack: 275 ,
    critical_strike_damage: 0.2 ,
    agility: 100 ,
    luck: 100 ,
    legendary_effect_name: "Chaos Reign",
    legendary_effect_description: "50% chance to attack an additional time for 50% of your damage.",
    description: "Unleash relentless waves of chaos and ruin with each draw of its string.",
    image_path: 'app/assets/images/legendary_items/havoc.jpg'
  },
  {
    name: "Helion",
    item_type: "One-handed Weapon",
    item_class: "Sword",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    min_spellpower: 114 ,
    max_spellpower: 190 ,
    global_damage: 0.10,
    legendary_effect_name: "Solar Flare",
    legendary_effect_description: "When dealing a Critical Strike with an attack :<br>
    Your Spellpower is increased by 20%.",
    description: "It blazes with the eternal light of the sun, scorching darkness and igniting hope.",
    image_path: 'app/assets/images/legendary_items/helion.jpg'
  },
  {
    name: "Hellbound",
    item_type: "Two-handed Weapon",
    item_class: "Axe",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    min_attack: 76 ,
    max_attack: 380 ,
    health: 1000,
    strength: 400 ,
    legendary_effect_name: "Might of the Underworld",
    legendary_effect_description: "10% chance to attack an additional time for 150% of your damage",
    description: "Unleash the wrath of the underworld upon your foes.",
    image_path: 'app/assets/images/legendary_items/hellbound.jpg'
  },
  {
    name: "Laceration",
    item_type: "One-handed Weapon",
    item_class: "Dagger",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    min_attack: 76 ,
    max_attack: 95 ,
    strength: 100 ,
    agility: 100 ,
    luck: 100 ,
    critical_strike_damage: 0.5 ,
    legendary_effect_name: "Lethal Strikes",
    legendary_effect_description: "At the end of your turn :<br>
    Inflict 50% physical damage.",
    description: "Each strike leaves behind a lingering sensation of otherworldly torment.",
    image_path: 'app/assets/images/legendary_items/laceration.jpg'
  },
  {
    name: "Necroclasp",
    item_type: "Hands",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 900 ,
    armor: 75 ,
    magic_resistance: 30 ,
    dreadmight: 100 ,
    willpower: 100 ,
    luck: 100 ,
    poison_resistance: 100,
    legendary_effect_name: "Vile Embrace",
    legendary_effect_description: "At the end of your turn :<br>
    You lose 6% of your Maximum Health.<br>
    Your Necrosurge is increased by 3%.",
    description: "In the clasp of death, even the fallen serve.",
    image_path: 'app/assets/images/legendary_items/necroclasp.jpg'
  },
  {
    name: "Nemesis",
    item_type: "Two-handed Weapon",
    item_class: "Staff",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    min_spellpower: 66 ,
    max_spellpower: 440 ,
    all_attributes: 50,
    intelligence: 100 ,
    agility: 100 ,
    luck: 100 ,
    legendary_effect_name: "Enemy of Life",
    legendary_effect_description: "You deal 50% increased damage to opponents above 70% Health.",
    description: "Become the enemy of a nation. The doom of an entire kingdom.",
    image_path: 'app/assets/images/legendary_items/nemesis.jpg'
  },
  {
    name: "Nethil",
    item_type: "One-handed Weapon",
    item_class: "Sword",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    min_necrosurge: 38 ,
    max_necrosurge: 63 ,
    health: 500,
    dreadmight: 100 ,
    willpower: 100 ,
    poison_resistance: 100,
    legendary_effect_name: "Necrotic Touch",
    legendary_effect_description: "At the end of your turn :<br>
    Deal 333 shadow damage and heal for that same amount.<br>
    Cannot Crit or Miss.",
    description: "Go now, for the blade hungers for more souls.",
    image_path: 'app/assets/images/legendary_items/nethil.jpg'
  },
  {
    name: "Rise of the Phoenix",
    item_type: "Chest",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 1300 ,
    armor: 75 ,
    magic_resistance: 75 ,
    strength: 100 ,
    agility: 100 ,
    luck: 100 ,
    fire_resistance: 100,
    legendary_effect_name: "Inferno Heart",
    legendary_effect_description: "When dealing a Critical Strike with an attack :<br>
    Inflict 30% of initial attack damage as additional fire damage.<br>
    Cannot Crit or Miss.",
    description: "Embrace the inferno within and leave only ashes in your wake.",
    image_path: 'app/assets/images/legendary_items/riseofthephoenix.jpg'
  },
  {
    name: "Ruler of Storms",
    item_type: "One-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    min_attack: 21 ,
    max_attack: 265 ,
    intelligence: 100 ,
    strength: 100 ,
    willpower: 100 ,
    lightning_resistance: 100,
    legendary_effect_name: "Sentence of the Skies",
    legendary_effect_description: "After attacking :<br>
    Inflict 40% of initial attack damage as additional lightning damage.<br>
    Cannot Crit or Miss.",
    description: "Shaping destiny with each resounding strike",
    image_path: 'app/assets/images/legendary_items/rulerofstorms.jpg'
  },
  {
    name: "Arcane Weavers",
    item_type: "Hands",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 300 ,
    armor: 30 ,
    magic_resistance: 75 ,
    intelligence: 400 ,
    legendary_effect_name: "Arcane Tempest",
    legendary_effect_description: "At the end of your turn :<br>
    Inflict 20% magic damage.",
    description: "Let fury reign down upon those who dare oppose the will of the storm.",
    image_path: 'app/assets/images/legendary_items/arcaneweavers.jpg'
  },
  {
    name: "Grand Arcanist Band",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    intelligence: 100 ,
    critical_strike_chance: 5.0 ,
    critical_strike_damage: 0.50 ,
    all_attributes: 50,
    legendary_effect_name: "Arcane's Embrace",
    legendary_effect_description: "At the end of you turn :<br>
    Inflict 18% magic damage.",
    description: "Forged in the heart of thunder, baptized by the fury of the winds.",
    image_path: 'app/assets/images/legendary_items/grandarcanistband.jpg'
  },
  {
    name: "The First Flame",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    health: 500 ,
    global_damage: 0.10 ,
    legendary_effect_name: "Flicker of Destruction",
    legendary_effect_description: "At the end of you turn :<br>
    10% chance to inflict 8% of opponent's Maximum Health as fire damage.<br>
    Cannot Crit or Miss.",
    description: "A reminder that from the flicker of a spark, entire worlds blaze into existence.",
    image_path: 'app/assets/images/legendary_items/thefirstflame.jpg'
  },
  {
    name: "The Nexus",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    legendary_effect_name: "Cosmic Resonance",
    legendary_effect_description: "Your damage always results in the highest outcome.",
    description: "It bends the fabric of reality, whispering secrets of the universe.",
    image_path: 'app/assets/images/legendary_items/thenexus.jpg'
  },
  {
    name: "Voidwalkers",
    item_type: "Feet",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 400 ,
    armor: 50 ,
    magic_resistance: 50 ,
    all_resistances: 50,
    luck: 100 ,
    agility: 100 ,
    strength: 100 ,
    legendary_effect_name: "Void Stride",
    legendary_effect_description: "Convert 100% of your Attack into Necrosurge when attacking.",
    description: "Within the Void lies the enigma of shadows, where silence and oblivion awaits",
    image_path: 'app/assets/images/legendary_items/voidwalkers.jpg'
  },
  {
    name: "Well of Souls",
    item_type: "Waist",
    item_class: "Belt",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 1000 ,
    armor: 40 ,
    magic_resistance: 40 ,
    damage_reduction: 0.05,
    intelligence: 100 ,
    willpower: 100 ,
    luck: 100 ,
    legendary_effect_name: "Life Drinker",
    legendary_effect_description: "When dealing a Critical Strike with an attack :<br>
    Heal for 6% of your Maximum Health.",
    description: "Only the very essence of your foes can now quench your thirst.",
    image_path: 'app/assets/images/legendary_items/wellofsouls.jpg'
  },

# More items go above ^
].each do |item_params|
  item = Item.new(item_params.except(:image_path))
  attach_image_to_item(item, item_params[:image_path])
  item.save
end
