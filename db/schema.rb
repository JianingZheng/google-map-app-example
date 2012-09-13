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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120913143654) do

  create_table "locations", :force => true do |t|
    t.string   "query"
    t.decimal  "latitude",    :precision => 13, :scale => 10
    t.decimal  "longitude",   :precision => 13, :scale => 10
    t.string   "street"
    t.string   "locality"
    t.string   "postal_code"
    t.string   "country"
    t.string   "precision"
    t.string   "region"
    t.string   "warning"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "locations", ["latitude", "longitude"], :name => "index_locations_on_latitude_and_longitude"
  add_index "locations", ["query"], :name => "index_locations_on_query"

end
