# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_16_182438) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "characters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "health", default: 100
    t.integer "attack", default: 10
    t.integer "armor", default: 5
    t.integer "spellpower", default: 10
    t.integer "magic_resistance", default: 5
    t.integer "strength", default: 5
    t.integer "intelligence", default: 5
    t.integer "luck", default: 5
    t.integer "willpower", default: 5
    t.string "race_image"
    t.string "character_class"
    t.string "race"
    t.bigint "user_id", null: false
    t.string "character_name"
    t.integer "level", default: 1
    t.integer "experience", default: 0
    t.integer "skill_points", default: 0
    t.integer "required_experience_for_next_level", default: 500
    t.bigint "hunt_id"
    t.bigint "main_hand"
    t.bigint "off_hand"
    t.bigint "head"
    t.bigint "chest"
    t.bigint "legs"
    t.bigint "neck"
    t.bigint "finger1"
    t.bigint "finger2"
    t.bigint "waist"
    t.bigint "hands"
    t.bigint "feet"
    t.string "gender"
    t.integer "agility", default: 5
    t.decimal "critical_strike_damage", precision: 5, scale: 2, default: "0.1"
    t.integer "max_health", default: 100
    t.integer "total_attack"
    t.integer "total_spellpower"
    t.integer "total_armor"
    t.integer "total_magic_resistance"
    t.decimal "total_critical_strike_damage", precision: 5, scale: 2
    t.integer "strength_bonus", default: 0
    t.integer "intelligence_bonus", default: 0
    t.integer "agility_bonus", default: 0
    t.decimal "critical_strike_chance", precision: 5, scale: 2, default: "1.0"
    t.decimal "total_critical_strike_chance", precision: 5, scale: 2
    t.integer "gold", default: 0
    t.integer "total_health"
    t.integer "total_max_health"
    t.integer "energy", default: 100
    t.integer "max_energy", default: 100
    t.integer "arena_ticket", default: 10
    t.integer "max_arena_ticket", default: 10
    t.integer "daily_quest", default: 10
    t.integer "max_daily_quest", default: 10
    t.integer "necrosurge", default: 10
    t.integer "total_necrosurge"
    t.integer "dreadmight", default: 5
    t.integer "dreadmight_bonus", default: 0
    t.integer "paragon_points", default: 0
    t.decimal "global_damage", precision: 6, scale: 3, default: "0.0"
    t.decimal "total_global_damage", precision: 6, scale: 3
    t.integer "paragon_increase_attack_count", default: 0
    t.integer "paragon_increase_armor_count", default: 0
    t.integer "paragon_increase_spellpower_count", default: 0
    t.integer "paragon_increase_magic_resistance_count", default: 0
    t.integer "paragon_increase_critical_strike_chance_count", default: 0
    t.integer "paragon_increase_critical_strike_damage_count", default: 0
    t.integer "paragon_increase_total_health_count", default: 0
    t.integer "paragon_increase_global_damage_count", default: 0
    t.decimal "paragon_attack", precision: 5, scale: 2, default: "0.0"
    t.decimal "paragon_armor", precision: 6, scale: 3, default: "0.0"
    t.decimal "paragon_spellpower", precision: 5, scale: 2, default: "0.0"
    t.decimal "paragon_magic_resistance", precision: 6, scale: 3, default: "0.0"
    t.decimal "paragon_critical_strike_chance", precision: 5, scale: 2, default: "0.0"
    t.decimal "paragon_critical_strike_damage", precision: 5, scale: 2, default: "0.0"
    t.decimal "paragon_total_health", precision: 6, scale: 3, default: "0.0"
    t.decimal "paragon_global_damage", precision: 6, scale: 3, default: "0.0"
    t.boolean "elixir_active", default: false
    t.integer "elixir_attack", default: 0
    t.integer "elixir_spellpower", default: 0
    t.integer "elixir_necrosurge", default: 0
    t.integer "elixir_armor", default: 0
    t.integer "elixir_magic_resistance", default: 0
    t.integer "elixir_global_damage", default: 0
    t.integer "elixir_total_health", default: 0
    t.bigint "active_elixir_ids", default: [], array: true
    t.integer "arena_rank", default: 0
    t.integer "min_attack", default: 20
    t.integer "max_attack", default: 20
    t.integer "min_spellpower", default: 20
    t.integer "max_spellpower", default: 20
    t.integer "min_necrosurge", default: 20
    t.integer "max_necrosurge", default: 20
    t.integer "total_min_attack"
    t.integer "total_max_attack"
    t.integer "total_min_spellpower"
    t.integer "total_max_spellpower"
    t.integer "total_min_necrosurge"
    t.integer "total_max_necrosurge"
    t.bigint "guild_id"
    t.index ["guild_id"], name: "index_characters_on_guild_id"
    t.index ["hunt_id"], name: "index_characters_on_hunt_id"
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "combat_results", force: :cascade do |t|
    t.bigint "character_id"
    t.bigint "opponent_id"
    t.string "opponent_type"
    t.text "combat_logs", default: [], array: true
    t.string "result"
    t.integer "opponent_health_in_combat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guilds", force: :cascade do |t|
    t.string "name"
    t.integer "leader_id"
    t.integer "membership_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hunts", force: :cascade do |t|
    t.string "name"
    t.integer "experience_reward"
    t.integer "level_requirement"
    t.integer "hunt_difficulty"
    t.integer "monster_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.bigint "character_id"
    t.integer "gold_reward"
    t.integer "energy_cost"
    t.bigint "combat_result_id"
    t.index ["character_id"], name: "index_hunts_on_character_id"
    t.index ["combat_result_id"], name: "index_hunts_on_combat_result_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_inventories_on_character_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "guild_id", null: false
    t.bigint "invited_character_id", null: false
    t.bigint "inviting_character_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guild_id"], name: "index_invitations_on_guild_id"
    t.index ["invited_character_id"], name: "index_invitations_on_invited_character_id"
    t.index ["inviting_character_id"], name: "index_invitations_on_inviting_character_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "strength"
    t.integer "intelligence"
    t.integer "luck"
    t.integer "willpower"
    t.integer "health"
    t.integer "attack"
    t.integer "armor"
    t.integer "spellpower"
    t.integer "magic_resistance"
    t.string "name", null: false
    t.text "description"
    t.string "item_type", null: false
    t.string "rarity"
    t.integer "character_id"
    t.integer "inventory_slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "item_image"
    t.string "inventory_type"
    t.bigint "inventory_id"
    t.integer "level_requirement"
    t.string "item_class"
    t.integer "upgrade", default: 0
    t.decimal "critical_strike_chance", precision: 5, scale: 2
    t.decimal "critical_strike_damage", precision: 5, scale: 2
    t.integer "agility"
    t.integer "gold_price"
    t.integer "necrosurge"
    t.integer "dreadmight"
    t.boolean "merchant_item", default: false
    t.boolean "purchased", default: false
    t.decimal "global_damage", precision: 6, scale: 3
    t.integer "duration"
    t.decimal "potion_heal_amount"
    t.decimal "potion_effect"
    t.datetime "elixir_applied_at"
    t.string "legendary_effect_name"
    t.string "legendary_effect_description"
    t.integer "min_attack"
    t.integer "max_attack"
    t.integer "min_spellpower"
    t.integer "max_spellpower"
    t.integer "min_necrosurge"
    t.integer "max_necrosurge"
    t.integer "upgraded_min_attack", default: 0
    t.integer "upgraded_max_attack", default: 0
    t.integer "upgraded_min_spellpower", default: 0
    t.integer "upgraded_max_spellpower", default: 0
    t.integer "upgraded_min_necrosurge", default: 0
    t.integer "upgraded_max_necrosurge", default: 0
    t.integer "upgraded_health", default: 0
    t.decimal "upgraded_global_damage", precision: 6, scale: 3, default: "0.0"
    t.decimal "upgraded_critical_strike_chance", precision: 5, scale: 2, default: "0.0"
    t.decimal "upgraded_critical_strike_damage", precision: 5, scale: 2, default: "0.0"
    t.integer "upgraded_armor", default: 0
    t.integer "upgraded_magic_resistance", default: 0
    t.integer "upgraded_strength", default: 0
    t.integer "upgraded_intelligence", default: 0
    t.integer "upgraded_agility", default: 0
    t.integer "upgraded_dreadmight", default: 0
    t.integer "upgraded_luck", default: 0
    t.integer "upgraded_willpower", default: 0
    t.boolean "generated_item", default: false
    t.index ["inventory_type", "inventory_id"], name: "index_items_on_inventory"
  end

  create_table "monsters", force: :cascade do |t|
    t.string "monster_name"
    t.integer "health", default: 100
    t.integer "attack", default: 10
    t.integer "armor", default: 5
    t.integer "magic_resistance", default: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "monster_image"
    t.integer "spellpower", default: 10
    t.integer "strength", default: 5
    t.integer "intelligence", default: 5
    t.integer "luck", default: 5
    t.integer "willpower", default: 5
    t.integer "agility", default: 5
    t.integer "level", default: 1
    t.decimal "critical_strike_damage", precision: 5, scale: 2, default: "1.2"
    t.integer "max_health", default: 100
    t.integer "total_attack"
    t.integer "total_spellpower"
    t.integer "total_armor"
    t.integer "total_magic_resistance"
    t.decimal "critical_strike_chance", precision: 5, scale: 2, default: "1.0"
    t.decimal "total_critical_strike_chance", precision: 5, scale: 2
    t.decimal "total_critical_strike_damage", precision: 5, scale: 2
    t.integer "strength_bonus", default: 0
    t.integer "intelligence_bonus", default: 0
    t.integer "agility_bonus", default: 0
    t.integer "total_health"
    t.integer "total_max_health"
    t.integer "necrosurge", default: 10
    t.integer "total_necrosurge"
    t.integer "dreadmight", default: 5
    t.integer "dreadmight_bonus", default: 0
    t.decimal "global_damage", precision: 6, scale: 3, default: "0.0"
    t.decimal "total_global_damage", precision: 6, scale: 3
    t.integer "min_attack", default: 20
    t.integer "max_attack", default: 20
    t.integer "min_spellpower", default: 20
    t.integer "max_spellpower", default: 20
    t.integer "min_necrosurge", default: 20
    t.integer "max_necrosurge", default: 20
    t.integer "total_min_attack"
    t.integer "total_max_attack"
    t.integer "total_min_spellpower"
    t.integer "total_max_spellpower"
    t.integer "total_min_necrosurge"
    t.integer "total_max_necrosurge"
  end

  create_table "quests", force: :cascade do |t|
    t.string "quest_type"
    t.integer "quest_monster_objective"
    t.integer "quest_objective"
    t.integer "experience_reward"
    t.integer "gold_reward"
    t.integer "level_requirement"
    t.text "description"
    t.string "name"
    t.bigint "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "row"
    t.integer "level_requirement"
    t.string "character_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "skill_image"
    t.bigint "character_id"
    t.boolean "locked", default: true
    t.boolean "unlocked"
    t.string "effect"
    t.string "skill_type"
    t.index ["character_id"], name: "index_skills_on_character_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "selected_character_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["selected_character_id"], name: "index_users_on_selected_character_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "characters", "guilds"
  add_foreign_key "characters", "hunts"
  add_foreign_key "characters", "items", column: "chest"
  add_foreign_key "characters", "items", column: "feet"
  add_foreign_key "characters", "items", column: "finger1"
  add_foreign_key "characters", "items", column: "finger2"
  add_foreign_key "characters", "items", column: "hands"
  add_foreign_key "characters", "items", column: "head"
  add_foreign_key "characters", "items", column: "legs"
  add_foreign_key "characters", "items", column: "main_hand"
  add_foreign_key "characters", "items", column: "neck"
  add_foreign_key "characters", "items", column: "off_hand"
  add_foreign_key "characters", "items", column: "waist"
  add_foreign_key "characters", "users"
  add_foreign_key "hunts", "characters"
  add_foreign_key "hunts", "combat_results"
  add_foreign_key "inventories", "characters"
  add_foreign_key "invitations", "characters", column: "invited_character_id"
  add_foreign_key "invitations", "characters", column: "inviting_character_id"
  add_foreign_key "invitations", "guilds"
  add_foreign_key "skills", "characters"
  add_foreign_key "users", "characters", column: "selected_character_id"
end
