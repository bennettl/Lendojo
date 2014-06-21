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

ActiveRecord::Schema.define(version: 20140619184735) do

  create_table "filters", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.boolean  "alert",      default: true
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lender_applications", force: true do |t|
    t.integer  "author_id"
    t.text     "categories"
    t.string   "skill"
    t.integer  "hours"
    t.text     "summary"
    t.string   "status",      default: "pending"
    t.text     "staff_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.integer  "lender_id"
    t.string   "main_img_file_name"
    t.string   "main_img_content_type"
    t.integer  "main_img_file_size"
    t.datetime "main_img_updated_at"
    t.string   "title"
    t.string   "headline"
    t.text     "summary"
    t.string   "location"
    t.integer  "price"
    t.string   "category"
    t.string   "tags"
    t.boolean  "hidden",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", force: true do |t|
    t.integer  "author_id"
    t.integer  "lender_id"
    t.integer  "stars",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: true do |t|
    t.integer  "author_id"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.string   "reason"
    t.text     "summary"
    t.text     "staff_notes"
    t.string   "status",          default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", force: true do |t|
    t.integer  "author_id"
    t.integer  "lender_id"
    t.string   "title"
    t.text     "summary"
    t.integer  "stars",      default: 0
    t.string   "category"
    t.string   "status",     default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rs_evaluations", force: true do |t|
    t.string   "reputation_name"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.float    "value",           default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rs_evaluations", ["reputation_name", "source_id", "source_type", "target_id", "target_type"], name: "index_rs_evaluations_on_reputation_name_and_source_and_target", unique: true
  add_index "rs_evaluations", ["reputation_name"], name: "index_rs_evaluations_on_reputation_name"
  add_index "rs_evaluations", ["source_id", "source_type"], name: "index_rs_evaluations_on_source_id_and_source_type"
  add_index "rs_evaluations", ["target_id", "target_type"], name: "index_rs_evaluations_on_target_id_and_target_type"

  create_table "rs_reputation_messages", force: true do |t|
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "receiver_id"
    t.float    "weight",      default: 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rs_reputation_messages", ["receiver_id", "sender_id", "sender_type"], name: "index_rs_reputation_messages_on_receiver_id_and_sender", unique: true
  add_index "rs_reputation_messages", ["receiver_id"], name: "index_rs_reputation_messages_on_receiver_id"
  add_index "rs_reputation_messages", ["sender_id", "sender_type"], name: "index_rs_reputation_messages_on_sender_id_and_sender_type"

  create_table "rs_reputations", force: true do |t|
    t.string   "reputation_name"
    t.float    "value",           default: 0.0
    t.string   "aggregated_by"
    t.integer  "target_id"
    t.string   "target_type"
    t.boolean  "active",          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rs_reputations", ["reputation_name", "target_id", "target_type"], name: "index_rs_reputations_on_reputation_name_and_target", unique: true
  add_index "rs_reputations", ["reputation_name"], name: "index_rs_reputations_on_reputation_name"
  add_index "rs_reputations", ["target_id", "target_type"], name: "index_rs_reputations_on_target_id_and_target_type"

  create_table "services", force: true do |t|
    t.integer  "lender_id"
    t.string   "main_img_file_name"
    t.string   "main_img_content_type"
    t.integer  "main_img_file_size"
    t.datetime "main_img_updated_at"
    t.string   "title"
    t.string   "headline"
    t.text     "summary"
    t.string   "location"
    t.integer  "price"
    t.string   "category"
    t.string   "tags"
    t.boolean  "hidden",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_services", force: true do |t|
    t.integer  "lender_id"
    t.integer  "lendee_id"
    t.integer  "service_id"
    t.string   "relationship_type"
    t.string   "status",            default: "pending"
    t.datetime "scheduled_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_services", ["lendee_id"], name: "index_user_services_on_lendee_id"
  add_index "user_services", ["lender_id"], name: "index_user_services_on_lender_id"
  add_index "user_services", ["service_id"], name: "index_user_services_on_service_id"

  create_table "users", force: true do |t|
    t.string   "main_img_file_name"
    t.string   "main_img_content_type"
    t.integer  "main_img_file_size"
    t.datetime "main_img_updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "headline"
    t.integer  "age"
    t.string   "email"
    t.string   "phone"
    t.boolean  "lender"
    t.string   "belt",                  default: "white"
    t.string   "skill_level"
    t.text     "summary"
    t.string   "location"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "stripe_customer_id"
    t.string   "status",                default: "inactive"
    t.string   "password_digest"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
