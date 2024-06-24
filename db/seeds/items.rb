# Method to attach image to item
def attach_image_to_item(item, image_path)
  item.item_image.attach(io: File.open(image_path), filename: File.basename(image_path), content_type: 'image/jpeg')
end
# Create items
[
### Amulets
  {
    name: "Ancient Pendant",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/amulets/ancientpendant.jpg'
  },
  {
    name: "Dragonblood Pendant",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/amulets/dragonbloodpendant.jpg'
  },
  {
    name: "Emerald Pendant",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/amulets/emeraldpendant.jpg'
  },
  {
    name: "Mystic Necklace",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/amulets/mysticnecklace.jpg'
  },
  {
    name: "Twilight Necklace",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/amulets/twilightnecklace.jpg'
  },
### Axes
  {
    name: "Executionner's Axe",
    item_type: "Two-handed Weapon",
    item_class: "Axe",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 121 ,
    max_attack: 608 ,
    image_path: 'app/assets/images/items/axes/executionersaxe.jpg'
  },
  {
    name: "Woodsplitter",
    item_type: "Two-handed Weapon",
    item_class: "Axe",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 121 ,
    max_attack: 608 ,
    image_path: 'app/assets/images/items/axes/woodsplitter.jpg'
  },
### Belts
  {
    name: "Leather Girdle",
    item_type: "Waist",
    item_class: "Belt",
    level_requirement: 100,
    gold_price: 57500,
    armor: 20 ,
    magic_resistance: 20 ,
    image_path: 'app/assets/images/items/belts/leathergirdle.jpg'
  },
  {
    name: "Primalist Waistband",
    item_type: "Waist",
    item_class: "Belt",
    level_requirement: 100,
    gold_price: 57500,
    armor: 20 ,
    magic_resistance: 20 ,
    image_path: 'app/assets/images/items/belts/primalistswaistband.jpg'
  },
  {
    name: "Warrior Waistband",
    item_type: "Waist",
    item_class: "Belt",
    level_requirement: 100,
    gold_price: 57500,
    armor: 20 ,
    magic_resistance: 20 ,
    image_path: 'app/assets/images/items/belts/warriorwaistband.jpg'
  },
### Bows
  {
    name: "Elven Longbow",
    item_type: "Two-handed Weapon",
    item_class: "Bow",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 294 ,
    max_attack: 440 ,
    image_path: 'app/assets/images/items/bows/elvenlongbow.jpg'
  },
  {
    name: "Flamefeather",
    item_type: "Two-handed Weapon",
    item_class: "Bow",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 294 ,
    max_attack: 440 ,
    image_path: 'app/assets/images/items/bows/flamefeather.jpg'
  },
  {
    name: "Frostwind",
    item_type: "Two-handed Weapon",
    item_class: "Bow",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 294 ,
    max_attack: 440 ,
    image_path: 'app/assets/images/items/bows/frostwind.jpg'
  },
  {
    name: "Lightningstrike",
    item_type: "Two-handed Weapon",
    item_class: "Bow",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 294 ,
    max_attack: 440 ,
    image_path: 'app/assets/images/items/bows/lightningstrike.jpg'
  },
  {
    name: "Plain Hunter's Bow",
    item_type: "Two-handed Weapon",
    item_class: "Bow",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 294 ,
    max_attack: 440 ,
    image_path: 'app/assets/images/items/bows/plainhuntersbow.jpg'
  },
### Cloth
  {
    name: "Acolyte's Crown",
    item_type: "Head",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    armor: 15 ,
    magic_resistance: 50 ,
    image_path: 'app/assets/images/items/cloth/acolytescrown.jpg'
  },
  {
    name: "Battlemage Garments",
    item_type: "Chest",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    armor: 25 ,
    magic_resistance: 70 ,
    image_path: 'app/assets/images/items/cloth/battlemagegarments.jpg'
  },
  {
    name: "Corruptor's Handswraps",
    item_type: "Hands",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    armor: 15 ,
    magic_resistance: 50 ,
    image_path: 'app/assets/images/items/cloth/corruptorshandwraps.jpg'
  },
  {
    name: "Enchanted Walkers",
    item_type: "Feet",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    armor: 15 ,
    magic_resistance: 50 ,
    image_path: 'app/assets/images/items/cloth/enchantedwalkers.jpg'
  },
  {
    name: "Linen Tunic",
    item_type: "Chest",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    armor: 25 ,
    magic_resistance: 70 ,
    image_path: 'app/assets/images/items/cloth/linentunic.jpg'
  },
  {
    name: "Padded Chestguard",
    item_type: "Chest",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    armor: 25 ,
    magic_resistance: 70 ,
    image_path: 'app/assets/images/items/cloth/paddedchestguard.jpg'
  },
  {
    name: "Wraith Vision",
    item_type: "Head",
    item_class: "Cloth",
    level_requirement: 100,
    gold_price: 57500,
    armor: 15 ,
    magic_resistance: 50 ,
    image_path: 'app/assets/images/items/cloth/wraithvision.jpg'
  },
### Daggers
  {
    name: "Blackfang",
    item_type: "One-handed Weapon",
    item_class: "Dagger",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 102 ,
    max_attack: 132 ,
    image_path: 'app/assets/images/items/daggers/blackfang.jpg'
  },
  {
    name: "Kingsbane",
    item_type: "One-handed Weapon",
    item_class: "Dagger",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 102 ,
    max_attack: 132 ,
    image_path: 'app/assets/images/items/daggers/kingsbane.jpg'
  },
  {
    name: "Runic Dagger",
    item_type: "One-handed Weapon",
    item_class: "Dagger",
    level_requirement: 100,
    gold_price: 57500,
    min_spellpower: 102 ,
    max_spellpower: 132 ,
    image_path: 'app/assets/images/items/daggers/runicdagger.jpg'
  },
### Leather
  {
    name: "Bandit Cloak",
    item_type: "Chest",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 50 ,
    image_path: 'app/assets/images/items/leather/banditcloak.jpg'
  },
  {
    name: "Darkhide Mitts",
    item_type: "Hands",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 35 ,
    magic_resistance: 35 ,
    image_path: 'app/assets/images/items/leather/darkhidemitts.jpg'
  },
  {
    name: "Fugitive Cap",
    item_type: "Head",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 35 ,
    magic_resistance: 35 ,
    image_path: 'app/assets/images/items/leather/fugitivecap.jpg'
  },
  {
    name: "Heavy Leather Vest",
    item_type: "Chest",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 50 ,
    image_path: 'app/assets/images/items/leather/heavyleathervest.jpg'
  },
  {
    name: "Hunter Hood",
    item_type: "Head",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 35 ,
    magic_resistance: 35 ,
    image_path: 'app/assets/images/items/leather/hunterhood.jpg'
  },
  {
    name: "Leather Treads",
    item_type: "Feet",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 35 ,
    magic_resistance: 35 ,
    image_path: 'app/assets/images/items/leather/leathertreads.jpg'
  },
  {
    name: "Malevolent Leather Wraps",
    item_type: "Chest",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 50 ,
    image_path: 'app/assets/images/items/leather/malevolentleatherwraps.jpg'
  },
  {
    name: "Omnious Stanglers",
    item_type: "Hands",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 35 ,
    magic_resistance: 35 ,
    image_path: 'app/assets/images/items/leather/omniousstranglers.jpg'
  },
  {
    name: "Prowler's Quicksteps",
    item_type: "Feet",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 35 ,
    magic_resistance: 35 ,
    image_path: 'app/assets/images/items/leather/prowlersquicksteps.jpg'
  },
  {
    name: "Rogue's Cowl",
    item_type: "Head",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 35 ,
    magic_resistance: 35 ,
    image_path: 'app/assets/images/items/leather/roguescowl.jpg'
  },
  {
    name: "Shadow shroud",
    item_type: "Chest",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 50 ,
    image_path: 'app/assets/images/items/leather/shadowshroud.jpg'
  },
  {
    name: "Swiftstride Boots",
    item_type: "Feet",
    item_class: "Leather",
    level_requirement: 100,
    gold_price: 57500,
    armor: 35 ,
    magic_resistance: 35 ,
    image_path: 'app/assets/images/items/leather/swiftstrideboots.jpg'
  },
### Maces
  {
    name: "Blessed Mace",
    item_type: "One-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    min_spellpower: 33 ,
    max_spellpower: 424 ,
    image_path: 'app/assets/images/items/maces/blessedmace.jpg'
  },
  {
    name: "Cerberus",
    item_type: "Two-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 58 ,
    max_attack: 728 ,
    image_path: 'app/assets/images/items/maces/cerberus.jpg'
  },
  {
    name: "Dwarven Hammer",
    item_type: "Two-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 58 ,
    max_attack: 728 ,
    image_path: 'app/assets/images/items/maces/dwarvenhammer.jpg'
  },
  {
    name: "Fortress Breaker",
    item_type: "Two-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 58 ,
    max_attack: 728 ,
    image_path: 'app/assets/images/items/maces/fortressbreaker.jpg'
  },
  {
    name: "Penance Hammer",
    item_type: "One-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    min_spellpower: 33 ,
    max_spellpower: 424 ,
    image_path: 'app/assets/images/items/maces/penancehammer.jpg'
  },
  {
    name: "Vicious Maul",
    item_type: "Two-handed Weapon",
    item_class: "Mace",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 58 ,
    max_attack: 728 ,
    image_path: 'app/assets/images/items/maces/viciousmaul.jpg'
  },
### Plate
  {
    name: "Armored Mitts",
    item_type: "Hands",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/armoredmitts.jpg'
  },
  {
    name: "Battleplate",
    item_type: "Chest",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 70 ,
    magic_resistance: 25 ,
    image_path: 'app/assets/images/items/plate/battleplate.jpg'
  },
  {
    name: "Crusader Bascinet",
    item_type: "Head",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/crusaderbascinet.jpg'
  },
  {
    name: "Dragonscale Greaves",
    item_type: "Feet",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/dragonscalegreaves.jpg'
  },
  {
    name: "Ebon Greathelm",
    item_type: "Head",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/ebongreathelm.jpg'
  },
  {
    name: "Gallant Helm",
    item_type: "Head",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/gallanthelm.jpg'
  },
  {
    name: "Knight's Cuirass",
    item_type: "Chest",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 70 ,
    magic_resistance: 25 ,
    image_path: 'app/assets/images/items/plate/knightscuirass.jpg'
  },
  {
    name: "Legionnaire Sabatons",
    item_type: "Feet",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/legionnairesabatons.jpg'
  },
  {
    name: "Mithril Chestguard",
    item_type: "Chest",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 70 ,
    magic_resistance: 25 ,
    image_path: 'app/assets/images/items/plate/mithrilchestguard.jpg'
  },
  {
    name: "Paladin Chestplate",
    item_type: "Chest",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 70 ,
    magic_resistance: 25 ,
    image_path: 'app/assets/images/items/plate/paladinchestplate.jpg'
  },
  {
    name: "Sentinel Barbute",
    item_type: "Head",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/sentinelsbarbute.jpg'
  },
  {
    name: "Templar Armor",
    item_type: "Chest",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 70 ,
    magic_resistance: 25 ,
    image_path: 'app/assets/images/items/plate/templararmor.jpg'
  },
  {
    name: "Templar Greaves",
    item_type: "Feet",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/templargreaves.jpg'
  },
  {
    name: "Warbringer Chestguard",
    item_type: "Chest",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 70 ,
    magic_resistance: 25 ,
    image_path: 'app/assets/images/items/plate/warbringerchestguard.jpg'
  },
  {
    name: "Warforged Grips",
    item_type: "Hands",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/warforgedgrips.jpg'
  },
  {
    name: "Wrathforged Helm",
    item_type: "Head",
    item_class: "Plate",
    level_requirement: 100,
    gold_price: 57500,
    armor: 50 ,
    magic_resistance: 15 ,
    image_path: 'app/assets/images/items/plate/wrathforgedhelm.jpg'
  },
### Rings
  {
    name: "Enchanted Ring",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/rings/enchantedring.jpg'
  },
  {
    name: "Hero's Signet",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/rings/herossignet.jpg'
  },
  {
    name: "Sapphire Band",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/rings/sapphireband.jpg'
  },
  {
    name: "Sapphire Loop",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/rings/sapphireloop.jpg'
  },
  {
    name: "Serpent Eye",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/rings/serpenteye.jpg'
  },
  {
    name: "Two-stone Ring",
    item_type: "Finger",
    item_class: "Ring",
    level_requirement: 100,
    gold_price: 57500,
    image_path: 'app/assets/images/items/rings/twostonering.jpg'
  },
### Shields
  {
    name: "Agile Defender",
    item_type: "Shield",
    item_class: "Small Shield",
    level_requirement: 100,
    gold_price: 57500,
    armor: 60,
    magic_resistance: 60,
    image_path: 'app/assets/images/items/shields/agiledefender.jpg'
  },
  {
    name: "Deathguard",
    item_type: "Shield",
    item_class: "Great Shield",
    level_requirement: 100,
    gold_price: 57500,
    armor: 120,
    magic_resistance: 60,
    image_path: 'app/assets/images/items/shields/deathguard.jpg'
  },
  {
    name: "Dwarven Greatshield",
    item_type: "Shield",
    item_class: "Great Shield",
    level_requirement: 100,
    gold_price: 57500,
    armor: 120,
    magic_resistance: 60,
    image_path: 'app/assets/images/items/shields/dwarvengreatshield.jpg'
  },
  {
    name: "Eagle Crest",
    item_type: "Shield",
    item_class: "Small Shield",
    level_requirement: 100,
    gold_price: 57500,
    armor: 60,
    magic_resistance: 60,
    image_path: 'app/assets/images/items/shields/eaglecrest.jpg'
  },
  {
    name: "Titanic Aegis",
    item_type: "Shield",
    item_class: "Great Shield",
    level_requirement: 100,
    gold_price: 57500,
    armor: 120,
    magic_resistance: 60,
    image_path: 'app/assets/images/items/shields/titanicaegis.jpg'
  },
### Staves
  {
    name: "Twilight Emissary",
    item_type: "Two-handed Weapon",
    item_class: "Staff",
    level_requirement: 100,
    gold_price: 57500,
    min_spellpower: 106,
    max_spellpower: 664,
    image_path: 'app/assets/images/items/staves/twilightemissary.jpg'
  },
### Swords
  {
    name: "Crystal Shortsword",
    item_type: "One-handed Weapon",
    item_class: "Sword",
    level_requirement: 100,
    gold_price: 57500,
    min_spellpower: 182,
    max_spellpower: 304,
    image_path: 'app/assets/images/items/swords/crystalshortsword.jpg'
  },
  {
    name: "Infused Longsword",
    item_type: "One-handed Weapon",
    item_class: "Sword",
    level_requirement: 100,
    gold_price: 57500,
    min_spellpower: 182,
    max_spellpower: 304,
    image_path: 'app/assets/images/items/swords/infusedlongsword.jpg'
  },
  {
    name: "Longsword",
    item_type: "One-handed Weapon",
    item_class: "Sword",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 182,
    max_attack: 304,
    image_path: 'app/assets/images/items/swords/longsword.jpg'
  },
].each do |item_params|
  item = Item.new(item_params.except(:image_path))
  attach_image_to_item(item, item_params[:image_path])
  item.save
end
