class ForgeController < ApplicationController

  def index
    @character = current_user.selected_character
    @items = @character.inventory.items
    @selected_item = Item.find_by(id: params[:item_id])
  end

  def upgrade_item_stat(item)
    stats = %i[health global_damage critical_strike_chance critical_strike_damage armor magic_resistance strength intelligence agility dreadmight luck willpower]
    available_stats = stats.select { |stat| item.respond_to?(stat) && item.send(stat).present? }
    @stat_to_upgrade = available_stats.sample

    case @stat_to_upgrade
      when :health
        upgrade_increase = (item.health * 0.10).round
        item.health += upgrade_increase
        item.upgraded_health += upgrade_increase
      when :global_damage
        upgrade_increase = (item.global_damage * 0.10).to_d
        item.global_damage += upgrade_increase
        item.upgraded_global_damage += upgrade_increase
      when :critical_strike_chance
        upgrade_increase = (item.critical_strike_chance * 0.10).to_d
        item.critical_strike_chance += upgrade_increase
        item.upgraded_critical_strike_chance += upgrade_increase
      when :critical_strike_damage
        upgrade_increase = (item.critical_strike_damage * 0.10).to_d
        item.critical_strike_damage += upgrade_increase
        item.upgraded_critical_strike_damage += upgrade_increase
      when :armor
        upgrade_increase = (item.armor * 0.10).round
        item.armor += upgrade_increase
        item.upgraded_armor += upgrade_increase
      when :magic_resistance
        upgrade_increase = (item.magic_resistance * 0.10).round
        item.magic_resistance += upgrade_increase
        item.upgraded_magic_resistance += upgrade_increase
      when :strength
        upgrade_increase = (item.strength * 0.10).round
        item.strength += upgrade_increase
        item.upgraded_strength += upgrade_increase
      when :intelligence
        upgrade_increase = (item.intelligence * 0.10).round
        item.intelligence += upgrade_increase
        item.upgraded_intelligence += upgrade_increase
      when :agility
        upgrade_increase = (item.agility * 0.10).round
        item.agility += upgrade_increase
        item.upgraded_agility += upgrade_increase
      when :dreadmight
        upgrade_increase = (item.dreadmight * 0.10).round
        item.dreadmight += upgrade_increase
        item.upgraded_dreadmight += upgrade_increase
      when :luck
        upgrade_increase = (item.luck * 0.10).round
        item.luck += upgrade_increase
        item.upgraded_luck += upgrade_increase
      when :willpower
        upgrade_increase = (item.willpower * 0.10).round
        item.willpower += upgrade_increase
        item.upgraded_willpower += upgrade_increase
      end
    item.save
  end

  def downgrade_item_stat(item)
    stats = %i[health global_damage critical_strike_chance critical_strike_damage armor magic_resistance strength intelligence agility dreadmight luck willpower]
    available_stats = stats.select { |stat| item.respond_to?(stat) && item.send(stat).present? }
    @stat_to_degrade = available_stats.sample

    case @stat_to_degrade
    when :health
      reduction_amount = (item.health * 0.10).round
      item.health -= reduction_amount
      item.upgraded_health -= reduction_amount
    when :global_damage
      reduction_amount = (item.global_damage * 0.10).to_d
      item.global_damage -= reduction_amount
      item.upgraded_global_damage -= reduction_amount
    when :critical_strike_chance
      reduction_amount = (item.critical_strike_chance * 0.10).to_d
      item.critical_strike_chance -= reduction_amount
      item.upgraded_critical_strike_chance -= reduction_amount
    when :critical_strike_damage
      reduction_amount = (item.critical_strike_damage * 0.10).to_d
      item.critical_strike_damage -= reduction_amount
      item.upgraded_critical_strike_damage -= reduction_amount
    when :armor
      reduction_amount = (item.armor * 0.10).round
      item.armor -= reduction_amount
      item.upgraded_armor -= reduction_amount
    when :magic_resistance
      reduction_amount = (item.magic_resistance * 0.10).round
      item.magic_resistance -= reduction_amount
      item.upgraded_magic_resistance -= reduction_amount
    when :strength
      reduction_amount = (item.strength * 0.10).round
      item.strength -= reduction_amount
      item.upgraded_strength -= reduction_amount
    when :intelligence
      reduction_amount = (item.intelligence * 0.10).round
      item.intelligence -= reduction_amount
      item.upgraded_intelligence -= reduction_amount
    when :agility
      reduction_amount = (item.agility * 0.10).round
      item.agility -= reduction_amount
      item.upgraded_agility -= reduction_amount
    when :dreadmight
      reduction_amount = (item.dreadmight * 0.10).round
      item.dreadmight -= reduction_amount
      item.upgraded_dreadmight -= reduction_amount
    when :luck
      reduction_amount = (item.luck * 0.10).round
      item.luck -= reduction_amount
      item.upgraded_luck -= reduction_amount
    when :willpower
      reduction_amount = (item.willpower * 0.10).round
      item.willpower -= reduction_amount
      item.upgraded_willpower -= reduction_amount
    end

    item.save
  end

  def upgrade_success_message
    "Upgrade successful. #{@item.name} upgraded to +#{@item.upgrade}: #{(@stat_to_upgrade.to_s.capitalize.humanize)} increased by 10%"
  end

  def upgrade_failure_message
    if @item.upgrade <= 10
      "Upgrade failed. #{@item.name} preserved at +#{@item.upgrade}"
    else
      "Upgrade failed. #{@item.name} downgraded to +#{@item.upgrade}: #{(@stat_to_degrade.to_s.capitalize.humanize)} decreased by 10%"
    end
  end

  def attempt_upgrade(success_rate)
    if rand(1..100) <= success_rate
      upgrade_item_stat(@item)
      @item.upgrade += 1
      @item.save
      flash[:notice] = upgrade_success_message
    else
      if @item.upgrade > 10
        downgrade_item_stat(@item)
        @item.upgrade -= 1
        @item.save
        flash[:alert] = upgrade_failure_message
      else
        flash[:alert] = upgrade_failure_message
      end
    end
  end

  def upgrade
    @character = current_user.selected_character
    @item = Item.find_by(id: params[:item_id])

    if @item.upgrade <= 5
      attempt_upgrade(100)
    elsif @item.upgrade > 5 && @item.upgrade <= 10
      attempt_upgrade(75)
    elsif @item.upgrade > 10 && @item.upgrade <= 15
      attempt_upgrade(50)
    elsif @item.upgrade > 15 && @item.upgrade <= 20
      attempt_upgrade(25)
    end

    redirect_to forge_index_path
  end
end
