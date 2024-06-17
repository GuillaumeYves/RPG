module ApplicationHelper
  def display_item_tooltip(item, character)
    content_tag(:div, class: "tooltip-content #{item.rarity&.downcase}", id: "tooltip_#{item.id}", style: 'min-width: 400px;') do
      item_name = item.name
      if item.upgrade.present? && !["Healing Potion", "Elixir"].include?(item.item_type)
        item_name += " +#{item.upgrade}" unless item.upgrade.zero?
      end
      concat(content_tag(:div, item_name, class: 'item-name'))
      concat(content_tag(:div, item.rarity.upcase, class: 'item-rarity')) if item.rarity.present?
      concat(content_tag(:div, "#{(item.duration / 3600).to_i} hours", class: 'item-duration')) if item.duration.present?
      concat(content_tag(:div, "Level : #{item.level_requirement}", class: 'item-level_requirement', style: 'font-size: small')) if item.level_requirement.present?
      concat(content_tag(:div, image_tag(item.item_image, alt: "#{item.class.name.downcase}_item", style: 'width: 200px; height: 200px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888; margin-bottom: 10px;'), class: 'item-image-tooltip'))
      concat(content_tag(:div, item.item_type, class: 'item-item_type', style: 'font-size: small')) if item.item_type.present?
      concat(content_tag(:div, item.item_class, class: 'item-item_class mb-3')) if item.item_class.present?
      concat(display_item_attributes(item, character))
      concat(content_tag(:div, item.description, class: 'item-description')) if item.description.present? && ["Healing Potion", "Elixir"].include?(item.item_type)
      concat(content_tag(:div, item.legendary_effect_name, class: 'item-legendary-effect-name mt-3')) if item.rarity == "Legendary" && item.legendary_effect_name.present?
      concat(content_tag(:div, class: 'mb-3') { content_tag(:small, simple_format(item.legendary_effect_description), class: 'item-legendary-effect-description') }) if item.rarity == "Legendary" && item.legendary_effect_description.present?
      concat(content_tag(:hr, '', style: 'width: 50%; margin: auto;', class: 'mt-3'))
      concat(content_tag(:div, item.description, class: 'item-description', style: 'font-size: smaller; font-style: italic;')) if item.description.present? && !["Healing Potion", "Elixir"].include?(item.item_type)
      concat(content_tag(:div, "#{number_with_delimiter(item.gold_price)} #{image_tag('misc/goldcoin.png', alt: 'Gold Coin', style: 'width: 20px; height: 20px; margin-bottom:3px;')}".html_safe, style: 'margin-top: 20px;', class: 'item-gold_price')) if item.gold_price.present?
    end
  end

  def display_item_attributes(item, character)
    attributes = %w(min_attack max_attack min_spellpower max_spellpower min_necrosurge max_necrosurge health global_damage critical_strike_chance critical_strike_damage armor magic_resistance strength intelligence agility dreadmight luck willpower)
    html = ""

    equipped_item = get_equipped_item(character, item.item_type)

    # Damage ranges
    attack_range = [item.min_attack, item.max_attack].compact.join(" - ")
    spellpower_range = [item.min_spellpower, item.max_spellpower].compact.join(" - ")
    necrosurge_range = [item.min_necrosurge, item.max_necrosurge].compact.join(" - ")

    if attack_range.present?
      average_attack = calculate_average(item.min_attack, item.max_attack)
      html += content_tag(:div, "Attack: #{attack_range} <small class='text-muted'>(~#{number_with_delimiter(average_attack.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-3')
    end
    if spellpower_range.present?
      average_spellpower = calculate_average(item.min_spellpower, item.max_spellpower)
      html += content_tag(:div, "Spellpower: #{spellpower_range} <small class='text-muted'>(~#{number_with_delimiter(average_spellpower.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-3')
    end
    if necrosurge_range.present?
      average_necrosurge = calculate_average(item.min_necrosurge, item.max_necrosurge)
      html += content_tag(:div, "Necrosurge: #{necrosurge_range} <small class='text-muted'>(~#{number_with_delimiter(average_necrosurge.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-3')
    end

    # Special attributes display
    attributes.each do |attribute|
      next if %w(min_attack max_attack min_spellpower max_spellpower min_necrosurge max_necrosurge).include?(attribute)

      if item.public_send(attribute).present?
        base_value = item.public_send(attribute)
        equipped_value = equipped_item&.public_send(attribute)

        # Determine if the attribute requires special display format
        case attribute
        when 'critical_strike_chance'
          base_value_display = "#{base_value}%"
          equipped_value_display = "#{equipped_value}%" if equipped_value
        when 'critical_strike_damage'
          base_value_display = "#{(base_value * 100).round(2)}%"
          equipped_value_display = "#{(equipped_value * 100).round(2)}%" if equipped_value
        when 'global_damage'
          base_value_display = number_to_percentage(base_value * 100, precision: 2)
          equipped_value_display = number_to_percentage(equipped_value * 100, precision: 2) if equipped_value
        else
          base_value_display = base_value
          equipped_value_display = equipped_value
        end

        # Check if there's an upgraded value for the attribute
        upgraded_value = item.upgraded_stats[attribute.to_sym]
        attribute_html = ""
        if upgraded_value.present? && upgraded_value != 0
          upgraded_value_display = case attribute
                                  when 'critical_strike_chance'
                                    "#{upgraded_value}%"
                                  when 'critical_strike_damage'
                                    "#{(upgraded_value * 100).round(2)}%"
                                  when 'global_damage'
                                    number_to_percentage(upgraded_value * 100, precision: 2)
                                  else
                                    upgraded_value
                                  end
          attribute_html += "(+<span'>#{upgraded_value_display}</span>)"
        end

        # Calculate difference and add indicator if equipped item exists
        if equipped_item
          if equipped_value.nil?
            # If there's no equipped value, show base value with upgrade
            difference_class = 'stat-increase'
            difference_symbol = '▲'
            difference_display = "#{difference_symbol} #{base_value_display} #{attribute_html}".html_safe
          else
            difference = base_value - equipped_value
            if difference != 0
              difference_class = difference.positive? ? 'stat-increase' : 'stat-decrease'
              difference_symbol = difference.positive? ? '▲' : '▼'
              difference_display = "#{difference_symbol} #{difference.abs}"
              if %w(critical_strike_chance critical_strike_damage global_damage).include?(attribute)
                difference_display += '%' # Append % for specific attributes
              end
              attribute_html += content_tag(:span, difference_display, class: difference_class)
            end
          end
        end

        html += content_tag(:div, "#{attribute.humanize}: #{base_value_display} #{attribute_html}".html_safe, class: 'tooltip-item-attribute')
      end
    end

    html.html_safe
  end

  def get_equipped_item(character, item_type)
    case item_type
    when 'Head'
      character.head
    when 'Chest'
      character.chest
    when 'Hands'
      character.hands
    when 'Feet'
      character.feet
    when 'Waist'
      character.waist
    when 'One-handed Weapon'
      character.main_hand
    when 'Two-handed Weapon'
      character.main_hand
    when 'Shield'
      character.off_hand
    when 'Finger'
      character.finger1
    when 'Neck'
      character.neck
    else
      nil
    end
  end

  def format_duration(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    seconds = seconds % 60

    "#{hours}:#{minutes}:#{seconds}"
  end

  def calculate_average(min_value, max_value)
    ((min_value + max_value) / 2.0).to_i
  end
end
