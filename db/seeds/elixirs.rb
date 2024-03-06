def create_item(name, item_type, potion_effect, duration, gold_price, description, image_path)
    item = Item.create!(
        name: name,
        item_type: item_type,
        potion_effect: potion_effect,
        duration: duration,
        gold_price: gold_price,
        description: description,
    )
    image_filename = "#{item.id}_#{File.basename(image_path)}"
    item.item_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end

  begin
    create_item("Elixir of Might", "Elixir", 0.10, 14400, 100, "Increase your Attack by 10% for 4 hours.",'app/assets/images/potions/elixirofmight.jpg')

    create_item("Elixir of Power", "Elixir", 0.10, 14400, 100, "Increase your Spellpower by 10% for 4 hours.",'app/assets/images/potions/elixirofpower.jpg')

    create_item("Elixir of Decay", "Elixir", 0.10, 14400, 100, "Increase your Necrosurge by 10% for 4 hours.",'app/assets/images/potions/elixirofdecay.jpg')

    create_item("Elixir of Fortitude", "Elixir", 0.10, 14400, 100, "Increase your Armor by 10% for 4 hours.",'app/assets/images/potions/elixiroffortitude.jpg')

    create_item("Elixir of Knowledge", "Elixir", 0.10, 14400, 100, "Increase your Magic Resistance by 10% for 4 hours.",'app/assets/images/potions/elixirofknowledge.jpg')

  end
