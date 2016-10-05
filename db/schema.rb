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

ActiveRecord::Schema.define(version: 20161005095624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name",               default: ""
    t.integer  "parent_id",          default: 0
    t.string   "url",                default: ""
    t.string   "permalink",          default: ""
    t.string   "site_permalink",     default: ""
    t.string   "icon_type",          default: ""
    t.string   "time_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "autor"
    t.integer  "product_id"
    t.text     "comment",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "name"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.string   "permalink"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "time_id"
    t.integer  "category_id"
    t.jsonb    "properties",         default: {}
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "code",               default: ""
    t.text     "description",        default: ""
    t.decimal  "price",              default: "0.0"
    t.jsonb    "sample_products",    default: {}
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "product_id"
    t.integer "comment_id"
    t.decimal "rating",     default: "4.5"
  end

end
