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
    min_attack: 384 ,
    max_attack: 640 ,
    strength: 300 ,
    luck: 100 ,
    willpower: 200 ,
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
    health: 1500 ,
    armor: 150 ,
    magic_resistance: 80 ,
    willpower: 600 ,
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
    health: 1000 ,
    armor: 75 ,
    magic_resistance: 30 ,
    strength: 300 ,
    luck: 200 ,
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
    min_attack: 368 ,
    max_attack: 550 ,
    intelligence: 250 ,
    agility: 250 ,
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
    min_spellpower: 228 ,
    max_spellpower: 380 ,
    intelligence: 500 ,
    luck: 100 ,
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
    min_attack: 152 ,
    max_attack: 760 ,
    strength: 400 ,
    luck: 200 ,
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
    min_attack: 152 ,
    max_attack: 190 ,
    strength: 200 ,
    agility: 200 ,
    luck: 200 ,
    legendary_effect_name: "Lethal Strikes",
    legendary_effect_description: "At the end of your turn :<br>
    Inflict 30% physical damage.",
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
    health: 1000 ,
    armor: 75 ,
    magic_resistance: 30 ,
    dreadmight: 300 ,
    willpower: 200 ,
    luck: 100 ,
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
    min_spellpower: 133 ,
    max_spellpower: 880 ,
    intelligence: 400 ,
    agility: 50 ,
    luck: 150 ,
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
    min_necrosurge: 114 ,
    max_necrosurge: 190 ,
    dreadmight: 400 ,
    willpower: 200 ,
    legendary_effect_name: "Necrotic Touch",
    legendary_effect_description: "At the end of your turn :<br>
    Deal 333 shadow damage and heal for that same amount.<br>
    Cannot Crit, Miss or be mitigated.",
    description: "Go now, for the blade hungers for more souls.",
    image_path: 'app/assets/images/legendary_items/nethil.jpg'
  },
  {
    name: "Pandemonium",
    item_type: "Chest",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 1800 ,
    armor: 75 ,
    magic_resistance: 75 ,
    strength: 200 ,
    agility: 200 ,
    luck: 200 ,
    legendary_effect_name: "Inferno Heart",
    legendary_effect_description: "When dealing a Critical Strike with an attack :<br>
    Inflict 22% of initial attack damage as additional fire damage.<br>
    Cannot Crit, Miss or be mitigated.",
    description: "Embrace the inferno within and leave only ashes in your wake.",
    image_path: 'app/assets/images/legendary_items/pandemonium.jpg'
  },
  {
    name: "Ruler of Storms",
    item_type: "One-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    min_attack: 42 ,
    max_attack: 530 ,
    intelligence: 250 ,
    strength: 250 ,
    willpower: 100 ,
    legendary_effect_name: "Sentence of the Skies",
    legendary_effect_description: "After attacking :<br>
    Inflict 40% of initial attack damage as additional magic damage.<br>
    Cannot Crit, Miss or be mitigated.",
    description: "Shaping destiny with each resounding strike",
    image_path: 'app/assets/images/legendary_items/rulerofstorms.jpg'
  },
  {
    name: "Stormweavers",
    item_type: "Hands",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 600 ,
    armor: 30 ,
    magic_resistance: 75 ,
    luck: 200 ,
    agility: 100 ,
    intelligence: 300 ,
    legendary_effect_name: "Arcane Tempest",
    legendary_effect_description: "At the end of your turn :<br>
    Inflict 20% magic damage.",
    description: "Let fury reign down upon those who dare oppose the will of the storm.",
    image_path: 'app/assets/images/legendary_items/stormweavers.jpg'
  },
  {
    name: "Tempest Band",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: 700 ,
    critical_strike_chance: 5.0 ,
    critical_strike_damage: 0.50 ,
    legendary_effect_name: "Stormcaller's Embrace",
    legendary_effect_description: "At the end of you turn :<br>
    Inflict 18% magic damage.",
    description: "Forged in the heart of thunder, baptized by the fury of the winds.",
    image_path: 'app/assets/images/legendary_items/tempestband.jpg'
  },
  {
    name: "The First Flame",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    health: 800 ,
    global_damage: 0.10 ,
    legendary_effect_name: "Flicker of Destruction",
    legendary_effect_description: "At the end of you turn :<br>
    10% chance to inflict 8% of opponent's Maximum Health as fire damage.<br>
    Cannot Crit, Miss or be mitigated.",
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
    health: 800 ,
    armor: 50 ,
    magic_resistance: 50 ,
    luck: 200 ,
    agility: 150 ,
    strength: 150 ,
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
    intelligence: 250 ,
    willpower: 250 ,
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
