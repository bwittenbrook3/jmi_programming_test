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

ActiveRecord::Schema.define(version: 20150911031025) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clsi_breakpoints", force: :cascade do |t|
    t.decimal  "s_maximum",                   precision: 9, scale: 5
    t.decimal  "r_minimum",                   precision: 9, scale: 5
    t.string   "r_if_surrogate_is"
    t.string   "ni_if_surrogate_is"
    t.string   "r_if_blt_is"
    t.string   "delivery_mechanism"
    t.string   "infection_type"
    t.string   "footnote"
    t.string   "master_group_include"
    t.string   "organism_group_include"
    t.string   "viridans_group_include"
    t.string   "genus_include"
    t.string   "genus_exclude"
    t.string   "organism_code_include"
    t.string   "organism_code_exclude"
    t.string   "gram_include"
    t.string   "level_1_include"
    t.string   "level_3_include"
    t.string   "level_3_exclude"
    t.string   "related_organism_codes_list"
    t.integer  "rule_row_number"
    t.integer  "drug_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "data_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "drugs", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "isolate_drug_reactions", force: :cascade do |t|
    t.string   "authority"
    t.string   "publication"
    t.string   "delivery_mechanism"
    t.string   "infection_type"
    t.integer  "isolate_id"
    t.integer  "drug_id"
    t.string   "reaction"
    t.string   "footnote"
    t.string   "eligible_interpretations"
    t.integer  "rule_row_number"
    t.string   "used_surrogate_drug_id"
    t.string   "used_surrogate_drug_ordinal"
    t.string   "used_surrogate_rule_type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
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
    t.integer  "isolate_id",                         null: false
    t.integer  "drug_id",                            null: false
    t.decimal  "mic_value",  precision: 9, scale: 5, null: false
    t.integer  "mic_edge",                           null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "organism_drug_breakpoints", force: :cascade do |t|
    t.integer  "organism_id",        null: false
    t.integer  "drug_id",            null: false
    t.integer  "clsi_breakpoint_id", null: false
    t.integer  "priority",           null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "delivery_mechanism"
    t.string   "infection_type"
  end

  add_index "organism_drug_breakpoints", ["clsi_breakpoint_id"], name: "index_organism_drug_breakpoints_on_clsi_breakpoint_id", using: :btree
  add_index "organism_drug_breakpoints", ["drug_id"], name: "index_organism_drug_breakpoints_on_drug_id", using: :btree
  add_index "organism_drug_breakpoints", ["organism_id", "drug_id", "clsi_breakpoint_id", "delivery_mechanism", "infection_type"], name: "index_drug_organism_breakpoint", unique: true, using: :btree
  add_index "organism_drug_breakpoints", ["organism_id"], name: "index_organism_drug_breakpoints_on_organism_id", using: :btree

  create_table "organisms", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.string   "genus"
    t.string   "species"
    t.string   "sub_species"
    t.string   "group"
    t.string   "master_group"
    t.string   "viridans_group"
    t.string   "level_1_class"
    t.string   "level_2_class"
    t.string   "level_3_class"
    t.string   "level_4_class"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "surrogate_drug_assignments", force: :cascade do |t|
    t.integer  "clsi_breakpoint_id"
    t.integer  "surrogate_drug_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

end
