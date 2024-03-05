def create_item(name, item_type, potion_heal_amount, level_requirement, gold_price, description, image_path)
    item = Item.create!(
        name: name,
        item_type: item_type,
        potion_heal_amount: potion_heal_amount,
        level_requirement: level_requirement,
        gold_price: gold_price,
        description: description,
    )
    image_filename = "#{item.id}_#{File.basename(image_path)}"
    item.item_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end

  begin
    create_item("Lesser Healing Potion", "Healing Potion", 0.05, 1, 2, "Heal for 5% of your Total Health.",'app/assets/images/potions/healing_potion.jpg')

    create_item("Minor Healing Potion", "Healing Potion", 0.10, 10, 8, "Heal for 10% of your Total Health.",'app/assets/images/potions/healing_potion.jpg')

    create_item("Healing Potion", "Healing Potion", 0.20, 25, 15, "Heal for 20% of your Total Health.",'app/assets/images/potions/healing_potion.jpg')

    create_item("Greater Healing Potion", "Healing Potion", 0.35, 50, 30, "Heal for 35% of your Total Health.",'app/assets/images/potions/healing_potion.jpg')

    create_item("Major Healing Potion", "Healing Potion", 0.50, 70, 50, "Heal for 50% of your Total Health.",'app/assets/images/potions/healing_potion.jpg')
  end
