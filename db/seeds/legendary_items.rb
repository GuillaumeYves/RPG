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
    min_attack: (384 * (rand(0.8..1.0))).to_i,
    max_attack: (640 * (rand(0.8..1.0))).to_i,
    strength: (229 * (rand(0.8..1.0))).to_i,
    luck: (145 * (rand(0.8..1.0))).to_i,
    willpower: (126 * (rand(0.8..1.0))).to_i,
    legendary_effect_name: "Dawn's Judgment",
    legendary_effect_description: "When opponent's Health reaches 10%:<br>
    Attempt to execute them for 111% of your damage.",
    description: "Cleave through enemies with righteous fury, bringing dawn's justice to any who would oppose it.",
    image_path: 'app/assets/images/legendary_items/dawnbreaker.jpg'
  },
  {
    name: "Hellbound",
    item_type: "Two-handed Weapon",
    item_class: "Axe",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    min_attack: (152 * (rand(0.8..1.0))).to_i,
    max_attack: (760 * (rand(0.8..1.0))).to_i,
    strength: (420 * (rand(0.8..1.0))).to_i,
    luck: (80 * (rand(0.8..1.0))).to_i,
    legendary_effect_name: "Might of the Underworld",
    legendary_effect_description: "Skullsplitter talent effect change:<br>
    Upon Critical Strike with a Basic attack, you attack once more for 70% of your damage.",
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
    min_attack: (252 * (rand(0.8..1.0))).to_i,
    max_attack: (290 * (rand(0.8..1.0))).to_i,
    strength: (205 * (rand(0.8..1.0))).to_i,
    agility: (205 * (rand(0.8..1.0))).to_i,
    luck: (90 * (rand(0.8..1.0))).to_i,
    legendary_effect_name: "Lethal Strikes",
    legendary_effect_description: "At the end of your turn:<br>
    Ambush your opponent for 30% of your damage.",
    description: "Each strike leaves behind a lingering sensation of otherworldly torment.",
    image_path: 'app/assets/images/legendary_items/laceration.jpg'
  },
  {
    name: "Nemesis",
    item_type: "Two-handed Weapon",
    item_class: "Staff",
    level_requirement: 100,
    gold_price: 86250,
    rarity: "Legendary",
    min_spellpower: (133 * (rand(0.8..1.0))).to_i,
    max_spellpower: (880 * (rand(0.8..1.0))).to_i,
    intelligence: (355 * (rand(0.8..1.0))).to_i,
    agility: (62 * (rand(0.8..1.0))).to_i,
    luck: (83 * (rand(0.8..1.0))).to_i,
    legendary_effect_name: "Enemy of Life",
    legendary_effect_description: "You deal 50% increased damage to enemies above 70% Health.",
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
    min_necrosurge: (228 * (rand(0.8..1.0))).to_i,
    max_necrosurge: (380 * (rand(0.8..1.0))).to_i,
    dreadmight: (355 * (rand(0.8..1.0))).to_i,
    luck: (145 * (rand(0.8..1.0))).to_i,
    legendary_effect_name: "Necrotic Touch",
    legendary_effect_description: "At the end of your turn:<br>
    Deal 333 shadow damage and heal for that same amount.<br>
    Cannot Crit, Miss or be mitigated.",
    description: "Go now, for the blade hungers for more souls.",
    image_path: 'app/assets/images/legendary_items/nethil.jpg'
  },
  {
    name: "Ruler of Storms",
    item_type: "One-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    min_attack: (42 * (rand(0.8..1.0))).to_i,
    max_attack: (530 * (rand(0.8..1.0))).to_i,
    intelligence: (298 * (rand(0.8..1.0))).to_i,
    strength: (145 * (rand(0.8..1.0))).to_i,
    luck: (57 * (rand(0.8..1.0))).to_i,
    legendary_effect_name: "Sentence of the Skies",
    legendary_effect_description: "On hit with Basic attack:<br>
    Trigger a thunderbolt dealing 20% of initial damage as additional magic damage.<br>
    Cannot Crit, Miss or be mitigated.",
    description: "Shaping destiny with each resounding strike",
    image_path: 'app/assets/images/legendary_items/rulerofstorms.jpg'
  },
  {
    name: "Tempest Band",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    rarity: "Legendary",
    health: (700 * (rand(0.8..1.0))).to_i,
    critical_strike_chance: (5.0 * (rand(0.8..1.0))),
    critical_strike_damage: (0.50 * (rand(0.80..1.0))),
    legendary_effect_name: "Stormcaller's Embrace",
    legendary_effect_description: "At the start of you turn:<br>
    Inflict 30% of your damage as magic damage.",
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
    health: (800 * (rand(0.8..1.0))).to_i,
    global_damage: (0.10 * (rand(0.8..1.0))),
    critical_strike_damage: (0.50 * (rand(0.8..1.0))),
    legendary_effect_name: "Flicker of Destruction",
    legendary_effect_description: "At the end of you turn:<br>
    10% chance to deal 8% of opponent's Maximum Health as fire damage.",
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
    health: (800 * (rand(0.8..1.0))).to_i,
    global_damage: (0.10 * (rand(0.8..1.0))),
    legendary_effect_name: "Cosmic Resonance",
    legendary_effect_description: "Your damage always results in the highest outcome.",
    description: "It bends the fabric of reality, whispering secrets of the universe.",
    image_path: 'app/assets/images/legendary_items/thenexus.jpg'
  },

# More items go above ^
].each do |item_params|
  item = Item.new(item_params.except(:image_path))
  attach_image_to_item(item, item_params[:image_path])
  item.save
end
