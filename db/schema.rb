# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171016152016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contact_groups", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_contact_groups_on_name", unique: true, using: :btree
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "fullname"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "label_templates", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "template_type"
    t.integer  "external_id",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "labware_types", force: :cascade do |t|
    t.integer  "num_of_cols"
    t.integer  "num_of_rows"
    t.boolean  "col_is_alpha"
    t.boolean  "row_is_alpha"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "uses_decapper", default: false, null: false
  end

  create_table "labwares", force: :cascade do |t|
    t.integer  "material_submission_id",             null: false
    t.integer  "labware_index",                      null: false
    t.integer  "print_count",            default: 0, null: false
    t.json     "contents"
    t.string   "barcode"
    t.string   "container_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["barcode"], name: "index_labwares_on_barcode", unique: true, using: :btree
    t.index ["container_id"], name: "index_labwares_on_container_id", unique: true, using: :btree
    t.index ["material_submission_id", "labware_index"], name: "index_labwares_on_material_submission_id_and_labware_index", unique: true, using: :btree
  end

  create_table "material_receptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "labware_id", null: false
    t.index ["labware_id"], name: "index_material_receptions_on_labware_id", unique: true, using: :btree
  end

  create_table "material_submissions", force: :cascade do |t|
    t.integer  "no_of_labwares_required"
    t.boolean  "supply_labwares"
    t.integer  "labware_type_id"
    t.string   "status"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "address"
    t.integer  "contact_id"
    t.uuid     "set_id"
    t.string   "material_submission_uuid"
    t.string   "owner_email"
    t.boolean  "dispatched",               default: false
    t.boolean  "supply_decappers",         default: false, null: false
    t.index ["contact_id"], name: "index_material_submissions_on_contact_id", using: :btree
    t.index ["labware_type_id"], name: "index_material_submissions_on_labware_type_id", using: :btree
    t.index ["owner_email"], name: "index_material_submissions_on_owner_email", using: :btree
  end

  create_table "printers", force: :cascade do |t|
    t.string   "name"
    t.string   "label_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_printers_on_name", unique: true, using: :btree
  end

  add_foreign_key "labwares", "material_submissions"
  add_foreign_key "material_receptions", "labwares"
  add_foreign_key "material_submissions", "contacts"
  add_foreign_key "material_submissions", "labware_types"
end
