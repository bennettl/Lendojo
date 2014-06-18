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

ActiveRecord::Schema.define(version: 20140525190222) do

  create_table "filters", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.boolean  "alert"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", force: true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.text     "summary"
    t.string   "location"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "stripe_customer_id"
    t.string   "password_digest"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
