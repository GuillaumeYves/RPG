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

ActiveRecord::Schema[7.1].define(version: 2024_01_15_210211) do
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
    t.text "selected_skills", default: ""
    t.integer "selected_skill_row_1"
    t.integer "selected_skill_row_2"
    t.integer "selected_skill_row_3"
    t.integer "selected_skill_row_4"
    t.index ["hunt_id"], name: "index_characters_on_hunt_id"
    t.index ["user_id"], name: "index_characters_on_user_id"
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
    t.index ["character_id"], name: "index_hunts_on_character_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_inventories_on_character_id"
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
    t.text "description", null: false
    t.string "item_type", null: false
    t.string "rarity", null: false
    t.integer "character_id"
    t.integer "inventory_slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "item_image"
    t.string "inventory_type"
    t.bigint "inventory_id"
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
  add_foreign_key "characters", "hunts"
  add_foreign_key "characters", "users"
  add_foreign_key "hunts", "characters"
  add_foreign_key "inventories", "characters"
  add_foreign_key "skills", "characters"
  add_foreign_key "users", "characters", column: "selected_character_id"
end
