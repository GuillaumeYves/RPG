#Rare items stats are increased by 5%
def create_item(name, item_type, item_class, level_requirement, rarity, stats = {}, description, image_path)
    item = Item.create!(
        name: name,
        item_type: item_type,
        item_class: item_class,
        level_requirement: level_requirement,
        rarity: rarity,
        description: description,
    )
    item.update(stats)
    image_filename = "#{item.id}_#{File.basename(image_path)}"
    item.item_image.attach(io: File.open(image_path), filename: image_filename, content_type: 'image/jpeg')
end

    begin
    end