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
    health: 640 ,
    critical_strike_chance: 8.0 ,
    image_path: 'app/assets/images/items/amulets/ancientpendant.jpg'
  },
  {
    name: "Radiant Talisman",
    item_type: "Neck",
    item_class: "Amulet",
    level_requirement: 100,
    gold_price: 57500,
    health: 640 ,
    critical_strike_damage: 0.80 ,
    image_path: 'app/assets/images/items/amulets/radianttalisman.jpg'
  },
### Axes
  {
    name: "Blackflame Reaper",
    item_type: "Two-handed Weapon",
    item_class: "Axe",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 121 ,
    max_attack: 608 ,
    image_path: 'app/assets/images/items/axes/blackflamereaper.jpg'
  },
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
    name: "Leather Girlde",
    item_type: "Waist",
    item_class: "Belt",
    level_requirement: 100,
    gold_price: 57500,
    health: 800 ,
    armor: 64 ,
    magic_resistance: 64 ,
    image_path: 'app/assets/images/items/belts/leathergirdle.jpg'
  },
  {
    name: "Primalist Waistband",
    item_type: "Waist",
    item_class: "Belt",
    level_requirement: 100,
    gold_price: 57500,
    health: 800 ,
    armor: 64 ,
    magic_resistance: 64 ,
    image_path: 'app/assets/images/items/belts/primalistswaistband.jpg'
  },
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
    min_spellpower: 294 ,
    max_spellpower: 440 ,
    image_path: 'app/assets/images/items/bows/flamefeather.jpg'
  },
  {
    name: "Lightningstrike",
    item_type: "Two-handed Weapon",
    item_class: "Bow",
    level_requirement: 100,
    gold_price: 57500,
    min_spellpower: 294 ,
    max_spellpower: 440 ,
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
  {
    name: "Seraph Bow",
    item_type: "Two-handed Weapon",
    item_class: "Bow",
    level_requirement: 100,
    gold_price: 57500,
    min_attack: 294 ,
    max_attack: 440 ,
    image_path: 'app/assets/images/items/bows/seraphbow.jpg'
  },
].each do |item_params|
  item = Item.new(item_params.except(:image_path))
  attach_image_to_item(item, item_params[:image_path])
  item.save
end
