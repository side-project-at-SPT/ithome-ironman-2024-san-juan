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

ActiveRecord::Schema[7.2].define(version: 2024_09_23_173105) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_steps", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.json "game_data", default: {}, null: false
    t.string "description"
    t.integer "steps", null: false
    t.integer "reason", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "steps"], name: "index_game_steps_on_game_id_and_steps", unique: true
    t.index ["game_id"], name: "index_game_steps_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "seed"
    t.string "version"
    t.json "game_data", default: {}
    t.json "result", default: {}
    t.integer "phase", default: 0, null: false
  end

  add_foreign_key "game_steps", "games"
end
