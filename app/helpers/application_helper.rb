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
      concat(content_tag(:div, image_tag(item.item_image, alt: "#{item.class.name.downcase}_item", style: 'width: 250px; height: 250px; border: 2px solid #000; box-shadow: 2px 2px 10px #888888;'), class: 'item-image-tooltip'))
      concat(content_tag(:div, item.item_type, class: 'item-item_type', style: 'font-size: small')) if item.item_type.present?
      concat(content_tag(:div, item.item_class, class: 'item-item_class mb-3', style: 'font-weight: 400')) if item.item_class.present?
      concat(display_item_attributes(item, character))
      concat(content_tag(:div, item.description, class: 'item-description')) if item.description.present? && ["Healing Potion", "Elixir"].include?(item.item_type)
      concat(content_tag(:div, item.legendary_effect_name, class: 'item-legendary-effect-name mt-3')) if item.rarity == "Legendary" && item.legendary_effect_name.present?
      concat(content_tag(:div, class: 'mb-3') { content_tag(:small, simple_format(item.legendary_effect_description), class: 'item-legendary-effect-description', style: 'font-size: small;') }) if item.rarity == "Legendary" && item.legendary_effect_description.present?
      concat(content_tag(:hr, '', style: 'width: 30%; margin: auto;', class: 'mt-3'))
      concat(content_tag(:div, item.description, class: 'item-description', style: 'font-size: smaller; font-style: italic;')) if item.description.present? && !["Healing Potion", "Elixir"].include?(item.item_type)
      concat(content_tag(:div, "#{number_with_delimiter(item.gold_price)} #{image_tag('misc/goldcoin.png', alt: 'Gold Coin', style: 'width: 20px; height: 20px; margin-bottom:3px;')}".html_safe, class: 'item-gold_price mt-2')) if item.gold_price.present?
    end
  end

  def display_item_attributes(item, character)
    attributes = %w(min_attack max_attack min_spellpower max_spellpower min_necrosurge max_necrosurge health global_damage critical_strike_chance critical_strike_damage armor magic_resistance critical_resistance fire_resistance cold_resistance lightning_resistance poison_resistance all_resistances all_attributes strength intelligence agility dreadmight luck willpower)
    html = ""
    equipped_item = get_equipped_item(character, item.item_type)
    # Damage ranges
    attack_range = [item.min_attack, item.max_attack].compact.join(" - ")
    spellpower_range = [item.min_spellpower, item.max_spellpower].compact.join(" - ")
    necrosurge_range = [item.min_necrosurge, item.max_necrosurge].compact.join(" - ")
    if attack_range.present?
      average_attack = calculate_average(item.min_attack, item.max_attack)
      upgraded_min_attack = item.upgraded_min_attack
      upgraded_max_attack = item.upgraded_max_attack
      min_attack_display = "#{item.min_attack}"
      max_attack_display = "#{item.max_attack}"
      if upgraded_min_attack.present? && upgraded_min_attack != 0
        min_attack_display += " <small class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<span class='text-#{upgraded_min_attack > 0 ? 'success' : 'danger'}'>#{upgraded_min_attack > 0 ? '+' : ''}#{upgraded_min_attack}</span>)</small>"
      end
      if upgraded_max_attack.present? && upgraded_max_attack != 0
        max_attack_display += " <small class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<span class='text-#{upgraded_max_attack > 0 ? 'success' : 'danger'}'>#{upgraded_max_attack > 0 ? '+' : ''}#{upgraded_max_attack}</span>)</small>"
      end
      html += content_tag(:div, "<span style='font-weight: 400'>Attack:</span> #{min_attack_display} - #{max_attack_display} <small class='text-muted'>(~#{number_with_delimiter(average_attack.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-2')
    end
    if spellpower_range.present?
      average_spellpower = calculate_average(item.min_spellpower, item.max_spellpower)
      upgraded_min_spellpower = item.upgraded_min_spellpower
      upgraded_max_spellpower = item.upgraded_max_spellpower
      min_spellpower_display = "#{item.min_spellpower}"
      max_spellpower_display = "#{item.max_spellpower}"
      if upgraded_min_spellpower.present? && upgraded_min_spellpower != 0
        min_spellpower_display += " <small class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<span class='text-#{upgraded_min_spellpower > 0 ? 'success' : 'danger'}'>#{upgraded_min_spellpower > 0 ? '+' : ''}#{upgraded_min_spellpower}</span>)</small>"
      end
      if upgraded_max_spellpower.present? && upgraded_max_spellpower != 0
        max_spellpower_display += " <small class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<span class='text-#{upgraded_max_spellpower > 0 ? 'success' : 'danger'}'>#{upgraded_max_spellpower > 0 ? '+' : ''}#{upgraded_max_spellpower}</span>)</small>"
      end
      html += content_tag(:div, "<span style='font-weight: 400'>Spellpower:</span> #{min_spellpower_display} - #{max_spellpower_display} <small class='text-muted'>(~#{number_with_delimiter(average_spellpower.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-2')
    end
    if necrosurge_range.present?
      average_necrosurge = calculate_average(item.min_necrosurge, item.max_necrosurge)
      upgraded_min_necrosurge = item.upgraded_min_necrosurge
      upgraded_max_necrosurge = item.upgraded_max_necrosurge
      min_necrosurge_display = "#{item.min_necrosurge}"
      max_necrosurge_display = "#{item.max_necrosurge}"
      if upgraded_min_necrosurge.present? && upgraded_min_necrosurge != 0
        min_necrosurge_display += " <small class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<span class='text-#{upgraded_min_necrosurge > 0 ? 'success' : 'danger'}'>#{upgraded_min_necrosurge > 0 ? '+' : ''}#{upgraded_min_necrosurge}</span>)</small>"
      end
      if upgraded_max_necrosurge.present? && upgraded_max_necrosurge != 0
        max_necrosurge_display += " <small class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<span class='text-#{upgraded_max_necrosurge > 0 ? 'success' : 'danger'}'>#{upgraded_max_necrosurge > 0 ? '+' : ''}#{upgraded_max_necrosurge}</span>)</small>"
      end
      html += content_tag(:div, "<span style='font-weight: 400'>Necrosurge:</span> #{min_necrosurge_display} - #{max_necrosurge_display} <small class='text-muted'>(~#{number_with_delimiter(average_necrosurge.to_i)})</small>".html_safe, class: 'tooltip-item-attribute mb-2')
    end

    # Health display
    if item.health.present?
      base_value = item.health
      equipped_value = equipped_item&.health
      upgraded_value = item.upgraded_health
      base_value_display = base_value
      equipped_value_display = equipped_value
      attribute_html = ""
        if upgraded_value.present? && upgraded_value.positive?
          attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-success'>+#{upgraded_value}</small>)</span>"
        elsif upgraded_value.present? && upgraded_value.negative? && upgraded_value != 0
          attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-danger'>#{upgraded_value}</small>)</span>"
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
      html += content_tag(:div, "<span style='font-weight: 400'>Health:</span> #{base_value_display} #{attribute_html}".html_safe, class: 'tooltip-item-attribute mb-2')
    end
    # Group 1: Armor, Magic Resistance, Critical Resistance, Damage Reduction
    grouped_attributes_1 = %w(armor magic_resistance critical_resistance damage_reduction)
    html += content_tag(:div, class: 'mb-2') do
      grouped_attributes_1.map do |attribute|
        if item.public_send(attribute).present?
          base_value = item.public_send(attribute)
          equipped_value = equipped_item&.public_send(attribute)
          base_value_display = case attribute
                              when 'damage_reduction'
                                 number_to_percentage(base_value * 100, precision: 2)
                              else
                                base_value
                              end
          equipped_value_display = case attribute
                                  when 'damage_reduction'
                                     number_to_percentage(equipped_value * 100, precision: 2) if equipped_value
                                  else
                                    equipped_value
                                  end
          upgraded_value = item.upgraded_stats[attribute.to_sym]
          attribute_html = ""
            if upgraded_value.present? && upgraded_value != 0
              upgraded_value_display = case attribute
                                      when 'damage_reduction'
                                         number_to_percentage(upgraded_value * 100, precision: 2)
                                      else
                                        upgraded_value
                                      end
              if upgraded_value.positive?
                attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-success'>+#{upgraded_value_display}</small>)</span>"
              elsif upgraded_value.negative?
                attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-danger'>#{upgraded_value_display}</small>)</span>"
              end
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
                # Conditionally append percentage display for damage_reduction
                if attribute == 'damage_reduction'
                  difference_display = "#{difference_symbol} #{number_to_percentage(difference.abs * 100, precision: 2)}"
                else
                  difference_display = "#{difference_symbol} #{difference.abs}"
                end
                attribute_html += content_tag(:span, difference_display, class: difference_class)
              end
            end
          end
          content_tag(:div, content_tag(:span, "#{attribute.humanize}: ", style: 'font-weight: 400') + "#{base_value_display} #{attribute_html}".html_safe, class: 'tooltip-item-attribute')
        end
      end.join.html_safe
    end
    # Group 2: Elemental Resistances
    grouped_attributes_2 = %w(fire_resistance cold_resistance lightning_resistance poison_resistance all_resistances)
    html += content_tag(:div, class: 'mb-2') do
      attributes.select { |attr| grouped_attributes_2.include?(attr) }.map do |attribute|
        if item.public_send(attribute).present?
          base_value = item.public_send(attribute)
          equipped_value = equipped_item&.public_send(attribute)
          base_value_display = base_value
          equipped_value_display = equipped_value
          upgraded_value = item.upgraded_stats[attribute.to_sym]
          attribute_html = ""
          if upgraded_value.present? && upgraded_value.positive?
            upgraded_value_display = upgraded_value
            attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-success'>+#{(upgraded_value_display)}</small>)</span>"
          elsif upgraded_value.present? && upgraded_value.negative? && upgraded_value != 0
            upgraded_value_display = upgraded_value
            attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-danger'>#{(upgraded_value_display)}</small>)</span>"
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
      end.compact.join.html_safe
    end
    # Group 3: Global Damage, Critical Strike Chance, Critical Strike Damage
    grouped_attributes_3 = %w(global_damage critical_strike_chance critical_strike_damage)
    html += content_tag(:div, class: 'mb-2') do
      grouped_attributes_3.map do |attribute|
        if item.public_send(attribute).present?
          base_value = item.public_send(attribute)
          equipped_value = equipped_item&.public_send(attribute)
          base_value_display = case attribute
                              when 'critical_strike_chance'
                                 number_to_percentage(base_value, precision: 2)
                              when 'critical_strike_damage'
                                 number_to_percentage(base_value * 100, precision: 2)
                              when 'global_damage'
                                 number_to_percentage(base_value * 100, precision: 2)
                              else
                                base_value
                              end
          equipped_value_display = case attribute
                                  when 'critical_strike_chance'
                                    number_to_percentage(equipped_value, precision: 2) if equipped_value
                                  when 'critical_strike_damage'
                                    number_to_percentage(equipped_value * 100, precision: 2) if equipped_value
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
                number_to_percentage(upgraded_value, precision: 2)
              when 'critical_strike_damage'
                number_to_percentage(upgraded_value * 100, precision: 2)
              when 'global_damage'
                number_to_percentage(upgraded_value * 100, precision: 2)
              else
                upgraded_value
              end
            if upgraded_value.present?
              if upgraded_value.positive?
                attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-success'>+#{upgraded_value_display}</small>)</span>"
              elsif upgraded_value.negative? && upgraded_value != 0
                attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-danger'>#{upgraded_value_display}</small>)</span>"
              end
            end
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
                # Conditionally append percentage display for crit damage and global damage
                if %w(critical_strike_damage global_damage).include?(attribute)
                  difference_display = "#{difference_symbol} #{number_to_percentage(difference.abs * 100, precision: 2)}"
                else
                  difference_display = "#{difference_symbol} #{number_to_percentage(difference.abs, precision: 2)}"
                end
                attribute_html += content_tag(:span, difference_display, class: difference_class)
              end
            end
          end
          content_tag(:div, content_tag(:span, "#{attribute.humanize}: ", style: 'font-weight: 400') + "#{base_value_display} #{attribute_html}".html_safe, class: 'tooltip-item-attribute')
        end
      end.join.html_safe
    end
    # Group 4: Remaining stats
    remaining_attributes = %w(all_attributes strength intelligence agility dreadmight luck willpower)
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
          attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-success'>+#{(upgraded_value_display)}</small>)</span>"
        elsif upgraded_value.present? && upgraded_value.negative? && upgraded_value != 0
          upgraded_value_display = upgraded_value
          attribute_html += "<span class='text-muted' style='font-size: smaller; vertical-align: sub; margin-left: -4px'>(<small class='text-danger'>#{(upgraded_value_display)}</small>)</span>"
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
    end.compact.join.html_safe
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
