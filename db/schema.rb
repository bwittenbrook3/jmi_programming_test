# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150905020932) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clsi_breakpoints", force: :cascade do |t|
    t.integer  "drug_id"
    t.decimal  "s_maximum"
    t.decimal  "r_minimum"
    t.integer  "surrogate_id"
    t.string   "r_if_surrogate_is"
    t.string   "ni_if_surrogate_is"
    t.string   "r_if_blt_is"
    t.string   "delivery_mechanism"
    t.string   "infection_type"
    t.string   "footnote"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "drugs", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "isolates", force: :cascade do |t|
    t.integer  "collection_no"
    t.integer  "site_id"
    t.integer  "study_year"
    t.integer  "bank_no"
    t.string   "organism_code"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "mic_results", force: :cascade do |t|
    t.integer  "isolate_id"
    t.integer  "drug_id"
    t.decimal  "mic_value"
    t.integer  "mic_edge"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisms", force: :cascade do |t|
    t.string   "organism_code"
    t.string   "organism_name"
    t.string   "genus"
    t.string   "species"
    t.string   "sub_species"
    t.string   "organism_group"
    t.string   "master_group"
    t.string   "viridans_group"
    t.string   "level_1_class"
    t.string   "level_2_class"
    t.string   "level_3_class"
    t.string   "level_4_class"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

end
