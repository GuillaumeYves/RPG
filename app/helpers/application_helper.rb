module ApplicationHelper
    def display_item_tooltip(item)
        content_tag(:div, class: "tooltip-content #{item.rarity.downcase}", id: "tooltip_#{item.id}") do
            concat(content_tag(:div, item.name, class: 'item-name'))
            concat(content_tag(:div, item.rarity.upcase, class: 'item-rarity'))
            concat(content_tag(:div, image_tag(item.item_image, alt: "#{item.class.name.downcase}_item", style: 'width: 200px; height: 200px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;'), class: 'item-image-tooltip'))
            concat(content_tag(:br))
            concat(display_item_attributes(item))
            concat(content_tag(:br))
            concat(content_tag(:hr, '', style: 'width: 50%; margin: auto; margin-bottom: 10px;'))
            concat(content_tag(:div, item.description, class: 'item-description'))
        end
    end

    def display_item_attributes(item)
        attributes = %w(strength intelligence luck willpower health attack armor spellpower magic_resistance)
        html = ""

        attributes.each do |attribute|
        if item.public_send(attribute).present?
            html += content_tag(:div, "#{attribute.humanize}: #{item.public_send(attribute)}", class: 'item-attribute')
        end
        end

        html.html_safe
    end

end
