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

ActiveRecord::Schema.define(version: 20170119170909) do

  create_table "barcodes", force: :cascade do |t|
    t.string   "barcode_type"
    t.string   "value"
    t.string   "barcodeable_type"
    t.integer  "barcodeable_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["barcodeable_type", "barcodeable_id"], name: "index_barcodes_on_barcodeable_type_and_barcodeable_id"
  end

  create_table "biomaterials", force: :cascade do |t|
    t.string   "uuid"
    t.string   "supplier_name"
    t.string   "donor_name"
    t.string   "gender"
    t.string   "common_name"
    t.string   "phenotype"
    t.string   "containable_type"
    t.integer  "containable_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["containable_type", "containable_id"], name: "index_biomaterials_on_containable_type_and_containable_id"
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
    t.integer  "x_dimension_size"
    t.integer  "y_dimension_size"
    t.boolean  "x_dimension_is_alpha"
    t.boolean  "y_dimension_is_alpha"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "labwares", force: :cascade do |t|
    t.integer  "labware_type_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["labware_type_id"], name: "index_labwares_on_labware_type_id"
  end

  create_table "material_receptions", force: :cascade do |t|
    t.integer  "labware_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["labware_id"], name: "index_material_receptions_on_labware_id"
  end

  create_table "material_submission_labwares", force: :cascade do |t|
    t.integer  "material_submission_id"
    t.integer  "labware_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.text     "state"
    t.index ["labware_id"], name: "index_material_submission_labwares_on_labware_id"
    t.index ["material_submission_id"], name: "index_material_submission_labwares_on_material_submission_id"
  end

  create_table "material_submissions", force: :cascade do |t|
    t.integer  "no_of_labwares_required"
    t.boolean  "supply_labwares"
    t.integer  "labware_type_id"
    t.string   "status"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "address"
    t.integer  "contact_id"
    t.string   "email"
    t.index ["contact_id"], name: "index_material_submissions_on_contact_id"
    t.index ["labware_type_id"], name: "index_material_submissions_on_labware_type_id"
  end

  create_table "wells", force: :cascade do |t|
    t.integer  "labware_id"
    t.string   "biomaterial_id"
    t.string   "position"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["labware_id"], name: "index_wells_on_labware_id"
  end

end
