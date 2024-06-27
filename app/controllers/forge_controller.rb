class ForgeController < ApplicationController
  def index
    @character = current_user.selected_character
    @items = @character.inventory.items
    @selected_item = Item.find_by(id: params[:item_id])
  end

  def upgrade_item_stat(item)
    stats = %i[health global_damage critical_strike_chance critical_strike_damage armor magic_resistance damage_reduction
    critical_resistance all_resistances fire_resistance cold_resistance lightning_resistance poison_resistance block_chance
    all_attributes strength intelligence agility dreadmight luck willpower
    min_attack max_attack min_spellpower max_spellpower min_necrosurge max_necrosurge]
    available_stats = stats.select { |stat| item.respond_to?(stat) && item.send(stat).present? }
    @stat_to_upgrade = available_stats.sample
    case @stat_to_upgrade
    when :health
      upgrade_increase = (item.initial_health * 0.02).to_i
      item.health += upgrade_increase
      item.upgraded_health += upgrade_increase
    when :global_damage
      upgrade_increase = (item.initial_global_damage * 0.02).to_d
      item.global_damage += upgrade_increase
      item.upgraded_global_damage += upgrade_increase
    when :critical_strike_chance
      upgrade_increase = (item.initial_critical_strike_chance * 0.02).to_d
      item.critical_strike_chance += upgrade_increase
      item.upgraded_critical_strike_chance += upgrade_increase
    when :critical_strike_damage
      upgrade_increase = (item.initial_critical_strike_damage * 0.02).to_d
      item.critical_strike_damage += upgrade_increase
      item.upgraded_critical_strike_damage += upgrade_increase
    when :armor
      upgrade_increase = (item.initial_armor * 0.02).to_i
      item.armor += upgrade_increase
      item.upgraded_armor += upgrade_increase
    when :magic_resistance
      upgrade_increase = (item.initial_magic_resistance * 0.02).to_i
      item.magic_resistance += upgrade_increase
      item.upgraded_magic_resistance += upgrade_increase
    when :damage_reduction
      upgrade_increase = (item.initial_damage_reduction * 0.02).to_d
      item.damage_reduction += [upgrade_increase, 0].max
      item.upgraded_damage_reduction += [upgrade_increase, 0].max
    when :critical_resistance
      upgrade_increase = (item.initial_critical_resistance * 0.02).to_i
      item.critical_resistance += [upgrade_increase, 0].max
      item.upgraded_critical_resistance += [upgrade_increase, 0].max
    when :all_resistances
      upgrade_increase = (item.initial_all_resistances * 0.02).to_i
      item.all_resistances += [upgrade_increase, 0].max
      item.upgraded_all_resistances += [upgrade_increase, 0].max
    when :fire_resistance
      upgrade_increase = (item.initial_fire_resistance * 0.02).to_i
      item.fire_resistance += [upgrade_increase, 0].max
      item.upgraded_fire_resistance += [upgrade_increase, 0].max
    when :cold_resistance
      upgrade_increase = (item.initial_cold_resistance * 0.02).to_i
      item.cold_resistance += [upgrade_increase, 0].max
      item.upgraded_cold_resistance += [upgrade_increase, 0].max
    when :lightning_resistance
      upgrade_increase = (item.initial_lightning_resistance * 0.02).to_i
      item.lightning_resistance += [upgrade_increase, 0].max
      item.upgraded_lightning_resistance += [upgrade_increase, 0].max
    when :poison_resistance
      upgrade_increase = (item.initial_poison_resistance * 0.02).to_i
      item.poison_resistance += [upgrade_increase, 0].max
      item.upgraded_poison_resistance += [upgrade_increase, 0].max
    when :block_chance
      upgrade_increase = (item.initial_block_chance * 0.02).to_i
      item.block_chance += [upgrade_increase, 0].max
      item.upgraded_block_chance += [upgrade_increase, 0].max
    when :all_attributes
      upgrade_increase = (item.initiam_all_attributes * 0.02).to_i
      item.all_attributes += [upgrade_increase, 0].max
      item.upgraded_all_attributes += [upgrade_increase, 0].max
    when :strength
      upgrade_increase = (item.initial_strength * 0.02).to_i
      item.strength += upgrade_increase
      item.upgraded_strength += upgrade_increase
    when :intelligence
      upgrade_increase = (item.initial_intelligence * 0.02).to_i
      item.intelligence += upgrade_increase
      item.upgraded_intelligence += upgrade_increase
    when :agility
      upgrade_increase = (item.initial_agility * 0.02).to_i
      item.agility += upgrade_increase
      item.upgraded_agility += upgrade_increase
    when :dreadmight
      upgrade_increase = (item.initial_dreadmight * 0.02).to_i
      item.dreadmight += upgrade_increase
      item.upgraded_dreadmight += upgrade_increase
    when :luck
      upgrade_increase = (item.initial_luck * 0.02).to_i
      item.luck += upgrade_increase
      item.upgraded_luck += upgrade_increase
    when :willpower
      upgrade_increase = (item.initial_willpower * 0.02).to_i
      item.willpower += upgrade_increase
      item.upgraded_willpower += upgrade_increase
    when :min_attack, :max_attack
      min_attack_increase = (item.initial_min_attack * 0.02).to_i
      max_attack_increase = (item.initial_max_attack * 0.02).to_i
      item.min_attack += min_attack_increase
      item.max_attack += max_attack_increase
      item.upgraded_min_attack += min_attack_increase
      item.upgraded_max_attack += max_attack_increase
    when :min_spellpower, :max_spellpower
      min_spellpower_increase = (item.initial_min_spellpower * 0.02).to_i
      max_spellpower_increase = (item.initial_max_spellpower * 0.02).to_i
      item.min_spellpower += min_spellpower_increase
      item.max_spellpower += max_spellpower_increase
      item.upgraded_min_spellpower += min_spellpower_increase
      item.upgraded_max_spellpower += max_spellpower_increase
    when :min_necrosurge, :max_necrosurge
      min_necrosurge_increase = (item.initial_min_necrosurge * 0.02).to_i
      max_necrosurge_increase = (item.initial_max_necrosurge * 0.02).to_i
      item.min_necrosurge += min_necrosurge_increase
      item.max_necrosurge += max_necrosurge_increase
      item.upgraded_min_necrosurge += min_necrosurge_increase
      item.upgraded_max_necrosurge += max_necrosurge_increase
    end
    item.save
  end

  def downgrade_item_stat(item)
    stats = %i[health global_damage critical_strike_chance critical_strike_damage armor magic_resistance damage_reduction
    critical_resistance all_resistances fire_resistance cold_resistance lightning_resistance poison_resistance block_chance
    all_attributes strength intelligence agility dreadmight luck willpower
    min_attack max_attack min_spellpower max_spellpower min_necrosurge max_necrosurge]
    available_stats = stats.select { |stat| item.respond_to?(stat) && item.send(stat).present? }
    @stat_to_degrade = available_stats.sample
    case @stat_to_degrade
    when :health
      reduction_amount = (item.initial_health * 0.02).round
      item.health -= [reduction_amount, 0].max
      item.upgraded_health -= [reduction_amount, 0].max
    when :global_damage
      reduction_amount = (item.initial_global_damage * 0.02).to_d
      item.global_damage -= [reduction_amount, 0].max
      item.upgraded_global_damage -= [reduction_amount, 0].max
    when :critical_strike_chance
      reduction_amount = (item.initial_critical_strike_chance * 0.02).to_d
      item.critical_strike_chance -= [reduction_amount, 0].max
      item.upgraded_critical_strike_chance -= [reduction_amount, 0].max
    when :critical_strike_damage
      reduction_amount = (item.initial_critical_strike_damage * 0.02).to_d
      item.critical_strike_damage -= [reduction_amount, 0].max
      item.upgraded_critical_strike_damage -= [reduction_amount, 0].max
    when :armor
      reduction_amount = (item.initial_armor * 0.10).round
      item.armor -= [reduction_amount, 0].max
      item.upgraded_armor -= [reduction_amount, 0].max
    when :magic_resistance
      reduction_amount = (item.initial_magic_resistance * 0.02).round
      item.magic_resistance -= [reduction_amount, 0].max
      item.upgraded_magic_resistance -= [reduction_amount, 0].max
    when :damage_reduction
      reduction_amount = (item.initial_damage_reduction * 0.02).to_d
      item.damage_reduction -= [reduction_amount, 0].max
      item.upgraded_damage_reduction -= [reduction_amount, 0].max
    when :critical_resistance
      reduction_amount = (item.initial_critical_resistance * 0.02).round
      item.critical_resistance -= [reduction_amount, 0].max
      item.upgraded_critical_resistance -= [reduction_amount, 0].max
    when :all_resistances
      reduction_amount = (item.initial_all_resistances * 0.02).round
      item.all_resistances -= [reduction_amount, 0].max
      item.upgraded_all_resistances -= [reduction_amount, 0].max
    when :fire_resistance
      reduction_amount = (item.initial_fire_resistance * 0.02).round
      item.fire_resistance -= [reduction_amount, 0].max
      item.upgraded_fire_resistance -= [reduction_amount, 0].max
    when :cold_resistance
      reduction_amount = (item.initial_cold_resistance * 0.02).round
      item.cold_resistance -= [reduction_amount, 0].max
      item.upgraded_cold_resistance -= [reduction_amount, 0].max
    when :lightning_resistance
      reduction_amount = (item.initial_lightning_resistance * 0.02).round
      item.lightning_resistance -= [reduction_amount, 0].max
      item.upgraded_lightning_resistance -= [reduction_amount, 0].max
    when :poison_resistance
      reduction_amount = (item.initial_poison_resistance * 0.02).round
      item.poison_resistance -= [reduction_amount, 0].max
      item.upgraded_poison_resistance -= [reduction_amount, 0].max
    when :block_chance
      reduction_amount = (item.initial_block_chance * 0.02).to_i
      item.block_chance -= [reduction_amount, 0].max
      item.upgraded_block_chance -= [reduction_amount, 0].max
    when :all_attributes
      reduction_amount = (item.initiam_all_attributes * 0.02).round
      item.all_attributes -= [reduction_amount, 0].max
      item.upgraded_all_attributes -= [reduction_amount, 0].max
    when :strength
      reduction_amount = (item.initial_strength * 0.02).round
      item.strength -= [reduction_amount, 0].max
      item.upgraded_strength -= [reduction_amount, 0].max
    when :intelligence
      reduction_amount = (item.initial_intelligence * 0.02).round
      item.intelligence -= [reduction_amount, 0].max
      item.upgraded_intelligence -= [reduction_amount, 0].max
    when :agility
      reduction_amount = (item.initial_agility * 0.02).round
      item.agility -= [reduction_amount, 0].max
      item.upgraded_agility -= [reduction_amount, 0].max
    when :dreadmight
      reduction_amount = (item.initial_dreadmight * 0.02).round
      item.dreadmight -= [reduction_amount, 0].max
      item.upgraded_dreadmight -= [reduction_amount, 0].max
    when :luck
      reduction_amount = (item.initial_luck * 0.02).round
      item.luck -= [reduction_amount, 0].max
      item.upgraded_luck -= [reduction_amount, 0].max
    when :willpower
      reduction_amount = (item.initial_willpower * 0.02).round
      item.willpower -= [reduction_amount, 0].max
      item.upgraded_willpower -= [reduction_amount, 0].max
    when :min_attack, :max_attack
      min_attack_decrease = (item.initial_min_attack * 0.02).round
      max_attack_decrease = (item.initial_max_attack * 0.02).round
      item.min_attack -= [min_attack_decrease, 0].max
      item.max_attack -= [max_attack_decrease, 0].max
      item.upgraded_min_attack -= [min_attack_decrease, 0].max
      item.upgraded_max_attack -= [max_attack_decrease, 0].max
    when :min_spellpower, :max_spellpower
      min_spellpower_decrease = (item.initial_min_spellpower * 0.02).round
      max_spellpower_decrease = (item.initial_max_spellpower * 0.02).round
      item.min_spellpower -= [min_spellpower_decrease, 0].max
      item.max_spellpower -= [max_spellpower_decrease, 0].max
      item.upgraded_min_spellpower -= [min_spellpower_decrease, 0].max
      item.upgraded_max_spellpower -= [max_spellpower_decrease, 0].max
    when :min_necrosurge, :max_necrosurge
      min_necrosurge_decrease = (item.initial_min_necrosurge * 0.02).round
      max_necrosurge_decrease = (item.initial_max_necrosurge * 0.02).round
      item.min_necrosurge -= [min_necrosurge_decrease, 0].max
      item.max_necrosurge -= [max_necrosurge_decrease, 0].max
      item.upgraded_min_necrosurge -= [min_necrosurge_decrease, 0].max
      item.upgraded_max_necrosurge -= [max_necrosurge_decrease, 0].max
    end

    item.save
  end

  def upgrade_success_message
    stat_name = case @stat_to_upgrade
                when :min_attack, :max_attack
                  "Attack"
                when :min_spellpower, :max_spellpower
                  "Spellpower"
                when :min_necrosurge, :max_necrosurge
                  "Necrosurge"
                else
                  (@stat_to_upgrade.to_s).titleize
                end
    ("Success<br>
    #{@item.name} upgraded to +#{@item.upgrade}<br>
    #{stat_name} increased").html_safe
  end

  def upgrade_failure_message
    stat_name = case @stat_to_degrade
                when :min_attack, :max_attack
                  "Attack"
                when :min_spellpower, :max_spellpower
                  "Spellpower"
                when :min_necrosurge, :max_necrosurge
                  "Necrosurge"
                else
                  (@stat_to_degrade.to_s).titleize
                end
    if @item.upgrade <= 10
      ("Failure<br>
      #{@item.name} preserved at +#{@item.upgrade}")
    else
      ("Failure<br>
      #{@item.name} downgraded to +#{@item.upgrade}<br>
      #{stat_name} decreased")
    end
  end

  def attempt_upgrade(success_rate)
    if rand(1..100) <= success_rate
      upgrade_item_stat(@item)
      @item.upgrade += 1
      @item.save
      flash[:info] = upgrade_success_message
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

    if @item.upgrade >= 0 && @item.upgrade <= 5
      attempt_upgrade(100)
    elsif @item.upgrade > 5 && @item.upgrade <= 9
      attempt_upgrade(80)
    elsif @item.upgrade > 9 && @item.upgrade <= 13
      attempt_upgrade(60)
    elsif @item.upgrade > 13 && @item.upgrade <= 17
      attempt_upgrade(30)
    elsif @item.upgrade > 17 && @item.upgrade <= 20
      attempt_upgrade(10)
    end
    redirect_to forge_index_path
  end
end
