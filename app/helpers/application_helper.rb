module ApplicationHelper
    def display_item_tooltip(item)
        content_tag(:div, class: "tooltip-content #{item.rarity.downcase}", id: "tooltip_#{item.id}", style: 'min-width: 400px;') do
            concat(content_tag(:div, item.name, class: 'item-name'))
            concat(content_tag(:div, item.rarity.upcase, class: 'item-rarity'))
            concat(content_tag(:div, "Level : " + item.level_requirement.to_s, class: 'item-level_requirement'))
            concat(content_tag(:div, "Upgrade : " + item.upgrade.to_s + "/5", class: 'item-upgrade'))
            concat(content_tag(:div, image_tag(item.item_image, alt: "#{item.class.name.downcase}_item", style: 'width: 200px; height: 200px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888; margin-bottom: 10px;'), class: 'item-image-tooltip'))
            concat(content_tag(:div, item.item_type, class: 'item-item_type'))
            concat(content_tag(:div, item.item_class, style: 'margin-bottom: 20px;' , class: 'item-item_class'))
            concat(display_item_attributes(item))
            concat(content_tag(:br))
            concat(content_tag(:hr, '', style: 'width: 50%; margin: auto; margin-bottom: 10px;'))
            concat(content_tag(:div, item.description, class: 'item-description', style: 'font-size: smaller; font-style: italic;')) if item.description.present?
            concat(content_tag(:div, number_with_delimiter(item.gold_price), style: 'margin-top: 20px;' , class: 'item-gold_price'))
        end
    end

    def display_item_attributes(item)
        attributes = %w(attack spellpower necrosurge critical_strike_chance critical_strike_damage health armor magic_resistance strength intelligence dreadmight agility luck willpower)
        html = ""

        attributes.each do |attribute|
            if item.public_send(attribute).present?
                value = item.public_send(attribute)

                if attribute == 'critical_strike_chance'
                    value = "#{value}%"
                elsif attribute == 'critical_strike_damage'
                    value = (value * 100).to_i.to_s + "%"
                end

                html += content_tag(:div, "#{attribute.humanize}: #{value}", class: 'tooltip-item-attribute')
            end
        end

        html.html_safe
    end

end
