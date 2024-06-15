class ForgeController < ApplicationController

  def index
    @character = current_user.selected_character
    @items = @character.inventory.items
    @selected_item = Item.find_by(id: params[:item_id])
  end

  def upgrade_item_stat(item)
    stats = %i[health global_damage critical_strike_chance critical_strike_damage armor magic_resistance strength intelligence agility dreadmight luck willpower]
    available_stats = stats.select { |stat| item.respond_to?(stat) && item.send(stat).present? }
    stat_to_upgrade = available_stats.sample

    case stat_to_upgrade
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

  def upgrade
    @character = current_user.selected_character
    @item = Item.find_by(id: params[:item_id])

    if @item.nil?
      flash[:alert] = "Item not found or does not belong to you!"
    elsif @item.upgrade < 5
      upgrade_item_stat(@item)
      @item.upgrade += 1
      @item.save
      flash[:notice] = "Item successfully upgraded and a random stat increased by 10%!"
    else
      flash[:alert] = "Item is already at maximum upgrade level!"
    end

    redirect_to forge_index_path
  end
end
