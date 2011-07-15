<<<<<<< HEAD
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

ActiveRecord::Schema.define(:version => 20110511151437) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  create_table "accountships", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "account_id",                    :null => false
    t.boolean  "admin",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accountships", ["account_id"], :name => "index_accountships_on_account_id"
  add_index "accountships", ["user_id", "account_id"], :name => "index_accountships_on_user_id_and_account_id", :unique => true
  add_index "accountships", ["user_id"], :name => "index_accountships_on_user_id"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "banner_text"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display_banner", :default => false
  end

  add_index "teams", ["name"], :name => "index_teams_on_name"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.string   "office_phone"
    t.string   "office_phone_ext"
    t.string   "home_phone"
    t.string   "mobile_phone"
    t.string   "forgot_hash"
    t.datetime "forgot_hash_created_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["forgot_hash"], :name => "index_users_on_forgot_hash", :unique => true

end
=======
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

ActiveRecord::Schema.define(:version => 20110525164437) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  create_table "accountships", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "account_id",                    :null => false
    t.boolean  "admin",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accountships", ["account_id"], :name => "index_accountships_on_account_id"
  add_index "accountships", ["user_id", "account_id"], :name => "index_accountships_on_user_id_and_account_id", :unique => true
  add_index "accountships", ["user_id"], :name => "index_accountships_on_user_id"

  create_table "memberships", :force => true do |t|
    t.integer  "team_id",                       :null => false
    t.integer  "user_id",                       :null => false
    t.boolean  "admin",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => true
  end

  add_index "memberships", ["active"], :name => "index_memberships_on_active"
  add_index "memberships", ["team_id", "user_id"], :name => "index_memberships_on_team_id_and_user_id", :unique => true

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "banner_text"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display_banner", :default => false
  end

  add_index "teams", ["name"], :name => "index_teams_on_name"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",                  :default => false
    t.string   "office_phone"
    t.string   "office_phone_ext"
    t.string   "home_phone"
    t.string   "mobile_phone"
    t.string   "forgot_hash"
    t.datetime "forgot_hash_created_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["forgot_hash"], :name => "index_users_on_forgot_hash", :unique => true

end
>>>>>>> 1c600e10b78d9ef609cba1cd2084c0e835159fe5
