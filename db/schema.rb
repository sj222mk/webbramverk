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

ActiveRecord::Schema.define(version: 20160811150228) do

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token"
    t.integer  "user_id"
    t.string   "description"
    t.datetime "expires_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token", unique: true
  add_index "api_keys", ["created_at"], name: "index_api_keys_on_created_at"
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id"

  create_table "creators", force: :cascade do |t|
    t.string   "email",                      null: false
    t.string   "displayname",     limit: 30, null: false
    t.string   "password_digest",            null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "locations", ["address"], name: "index_locations_on_address"

  create_table "places", force: :cascade do |t|
    t.integer  "creator_id",              null: false
    t.integer  "location_id",             null: false
    t.string   "placetype",   limit: 30,  null: false
    t.string   "placename",   limit: 30,  null: false
    t.integer  "grade",                   null: false
    t.text     "description", limit: 300, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "places", ["creator_id"], name: "index_places_on_creator_id"
  add_index "places", ["location_id"], name: "index_places_on_location_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",           default: false
  end

end
