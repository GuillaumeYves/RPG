module ApplicationHelper
  def display_item_tooltip(item, character)
    content_tag(:div, class: "tooltip-content #{item.rarity&.downcase}", id: "tooltip_#{item.id}", style: 'min-width: 400px;') do
      item_name = item.name

      if item.upgrade.present? && !["Healing Potion", "Elixir"].include?(item.item_type)
        upgrade_value = item.upgrade
        upgrade_text = "+#{upgrade_value}" unless upgrade_value.zero?

        if upgrade_text
          color_class =
            if upgrade_value.between?(1, 5)
              color_class = 'text-red-1'
            elsif upgrade_value.between?(6, 10)
              color_class = 'text-red-2'
            elsif upgrade_value.between?(11, 15)
              color_class = 'text-red-3'
            elsif upgrade_value.between?(16, 19)
              color_class = 'text-red-4'
            elsif upgrade_value == 20
              color_class = 'text-red-5'
            end
            upgrade_text = "<span class='#{color_class}' style='text-shadow: 1px 1px 1px black; font-size: large'>#{upgrade_text}</span>".html_safe
        end
        item_name += " #{upgrade_text}" if upgrade_text
      end

      concat(content_tag(:div, item_name.html_safe, class: 'item-name'))
      concat(content_tag(:div, item.rarity.upcase, class: 'item-rarity',style: 'margin-top: -8px;')) if item.rarity.present?
      concat(content_tag(:div, "#{(item.duration / 3600).to_i} hours", class: 'item-duration')) if item.duration.present?
      concat(content_tag(:div, "Level : #{item.level_requirement}", class: 'item-level_requirement', style: 'font-size: small')) if item.level_requirement.present?
      concat(content_tag(:div, image_tag(item.item_image, alt: "#{item.class.name.downcase}_item", style: 'width: 200px; height: 200px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;'), class: 'item-image-tooltip'))
      concat(content_tag(:div, item.item_type, class: 'item-item_type', style: 'font-size: small')) if item.item_type.present?
      concat(content_tag(:div, item.item_class, class: 'item-item_class mb-3', style: 'font-weight: 400')) if item.item_class.present?
      concat(display_item_attributes(item, character))
      concat(content_tag(:div, item.description, class: 'item-description')) if item.description.present? && ["Healing Potion", "Elixir"].include?(item.item_type)
      concat(content_tag(:div, item.legendary_effect_name, class: 'item-legendary-effect-name mt-3')) if item.rarity == "Legendary" && item.legendary_effect_name.present?
      concat(content_tag(:div, class: 'mb-3') { content_tag(:small, simple_format(item.legendary_effect_description), class: 'item-legendary-effect-description', style: 'font-size: small;') }) if item.rarity == "Legendary" && item.legendary_effect_description.present?
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
      html += content_tag(:div, "<span style= 'font-weight: 400'>Attack:</span> #{attack_range} <small class='text-muted'>(~#{number_with_delimiter(average_attack.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-2')
    end
    if spellpower_range.present?
      average_spellpower = calculate_average(item.min_spellpower, item.max_spellpower)
      html += content_tag(:div, "<span style= 'font-weight: 400'>Spellpower:</span> #{spellpower_range} <small class='text-muted'>(~#{number_with_delimiter(average_spellpower.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-2')
    end
    if necrosurge_range.present?
      average_necrosurge = calculate_average(item.min_necrosurge, item.max_necrosurge)
      html += content_tag(:div, "<span style= 'font-weight: 400'>Necrosurge:</span> #{necrosurge_range} <small class='text-muted'>(~#{number_with_delimiter(average_necrosurge.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-2')
    end

    if item.health.present?
      html += content_tag(:div, "<span style= 'font-weight: 400'>Health:</span> #{item.health}".html_safe, class: 'tooltip-item-attribute mb-2')
    end

    # Group 1: Health, Armor, Magic Resistance
    grouped_attributes_1 = %w(armor magic_resistance)
    html += content_tag(:div, class: 'mb-2') do
      grouped_attributes_1.map do |attribute|
        if item.public_send(attribute).present?
          base_value = item.public_send(attribute)
          equipped_value = equipped_item&.public_send(attribute)
          base_value_display = base_value
          equipped_value_display = equipped_value

          upgraded_value = item.upgraded_stats[attribute.to_sym]
          attribute_html = ""
          if upgraded_value.present? && upgraded_value != 0
            upgraded_value_display = upgraded_value
            attribute_html += "(+<span'>#{upgraded_value_display}</span>)"
          end

          if equipped_item
            if equipped_value.nil?
              difference_class = 'stat-increase'
              difference_symbol = '▲'
              difference_display = "#{difference_symbol} #{base_value_display} #{attribute_html}".html_safe
            else
              difference = base_value - equipped_value
              if difference != 0
                difference_class = difference.positive? ? 'stat-increase' : 'stat-decrease'
                difference_symbol = difference.positive? ? '▲' : '▼'
                difference_display = "#{difference_symbol} #{difference.abs}"
                attribute_html += content_tag(:span, difference_display, class: difference_class)
              end
            end
          end

          content_tag(:div, content_tag(:span, "#{attribute.humanize}: ", style: 'font-weight: 400') + "#{base_value_display} #{attribute_html}".html_safe, class: 'tooltip-item-attribute')
        end
      end.join.html_safe
    end

    # Group 2: Global Damage, Critical Strike Chance, Critical Strike Damage
    grouped_attributes_2 = %w(global_damage critical_strike_chance critical_strike_damage)
    html += content_tag(:div, class: 'mb-2') do
      grouped_attributes_2.map do |attribute|
        if item.public_send(attribute).present?
          base_value = item.public_send(attribute)
          equipped_value = equipped_item&.public_send(attribute)

          base_value_display = case attribute
                              when 'critical_strike_chance'
                                "#{base_value}%"
                              when 'critical_strike_damage'
                                "#{(base_value * 100).round(2)}%"
                              when 'global_damage'
                                number_to_percentage(base_value * 100, precision: 2)
                              else
                                base_value
                              end
          equipped_value_display = case attribute
                                  when 'critical_strike_chance'
                                    "#{equipped_value}%" if equipped_value
                                  when 'critical_strike_damage'
                                    "#{(equipped_value * 100).round(2)}%" if equipped_value
                                  when 'global_damage'
                                    number_to_percentage(equipped_value * 100, precision: 2) if equipped_value
                                  else
                                    equipped_value
                                  end

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

          if equipped_item
            if equipped_value.nil?
              difference_class = 'stat-increase'
              difference_symbol = '▲'
              difference_display = "#{difference_symbol} #{base_value_display} #{attribute_html}".html_safe
            else
              difference = base_value - equipped_value
              if difference != 0
                difference_class = difference.positive? ? 'stat-increase' : 'stat-decrease'
                difference_symbol = difference.positive? ? '▲' : '▼'
                difference_display = "#{difference_symbol} #{difference.abs}"
                difference_display += '%' if %w(critical_strike_chance critical_strike_damage global_damage).include?(attribute)
                attribute_html += content_tag(:span, difference_display, class: difference_class)
              end
            end
          end

          content_tag(:div, content_tag(:span, "#{attribute.humanize}: ", style: 'font-weight: 400') + "#{base_value_display} #{attribute_html}".html_safe, class: 'tooltip-item-attribute')
        end
      end.join.html_safe
    end

    # Group 3: Remaining stats
    remaining_attributes = attributes - %w(min_attack max_attack min_spellpower max_spellpower min_necrosurge max_necrosurge health global_damage critical_strike_chance critical_strike_damage armor magic_resistance)
    html += remaining_attributes.map do |attribute|
      if item.public_send(attribute).present?
        base_value = item.public_send(attribute)
        equipped_value = equipped_item&.public_send(attribute)
        base_value_display = base_value
        equipped_value_display = equipped_value

        upgraded_value = item.upgraded_stats[attribute.to_sym]
        attribute_html = ""
        if upgraded_value.present? && upgraded_value.positive?
          upgraded_value_display = upgraded_value
          attribute_html += "(<small class='text-success'>+#{upgraded_value_display}</small>)"
        elsif upgraded_value.present? && upgraded_value.negative? && upgraded_value != 0
          upgraded_value_display = upgraded_value
          attribute_html += "(<small class='text-danger'>#{upgraded_value_display}</small>)"
        end

        if equipped_item
          if equipped_value.nil?
            difference_class = 'stat-increase'
            difference_symbol = '▲'
            difference_display = "#{difference_symbol} #{base_value_display} #{attribute_html}".html_safe
          else
            difference = base_value - equipped_value
            if difference != 0
              difference_class = difference.positive? ? 'stat-increase' : 'stat-decrease'
              difference_symbol = difference.positive? ? '▲' : '▼'
              difference_display = "#{difference_symbol} #{difference.abs}"
              attribute_html += content_tag(:span, difference_display, class: difference_class)
            end
          end
        end

        content_tag(:div, content_tag(:span, "#{attribute.humanize}: ", style: 'font-weight: 400') + "#{base_value_display} #{attribute_html}".html_safe, class: 'tooltip-item-attribute')
      end
    end.join.html_safe

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
