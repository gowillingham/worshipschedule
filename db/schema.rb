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

ActiveRecord::Schema.define(:version => 20120209185316) do

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

  create_table "availabilities", :force => true do |t|
    t.integer  "membership_id",                    :null => false
    t.integer  "event_id",                         :null => false
    t.boolean  "free",          :default => false
    t.boolean  "approved",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "availabilities", ["event_id", "membership_id"], :name => "index_availabilities_on_event_id_and_membership_id", :unique => true

  create_table "event_memberships", :force => true do |t|
    t.integer  "membership_id"
    t.integer  "event_id"
    t.boolean  "available",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_memberships", ["event_id", "membership_id"], :name => "index_event_membership_on_event_id_and_membership_id", :unique => true

  create_table "events", :force => true do |t|
    t.integer  "team_id",                        :null => false
    t.string   "name",                           :null => false
    t.string   "description"
    t.datetime "start_at",                       :null => false
    t.datetime "end_at"
    t.boolean  "all_day",     :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["start_at"], :name => "index_events_on_start_at"
  add_index "events", ["team_id"], :name => "index_events_on_team_id"

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

  create_table "skills", :force => true do |t|
    t.integer  "team_id",     :null => false
    t.string   "name",        :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skills", ["name"], :name => "index_skills_on_name"

  create_table "skillships", :force => true do |t|
    t.integer  "membership_id", :null => false
    t.integer  "skill_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skillships", ["membership_id", "skill_id"], :name => "index_skillships_on_membership_id_and_skill_id", :unique => true

  create_table "slots", :force => true do |t|
    t.integer  "skillship_id", :null => false
    t.integer  "event_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "slots", ["event_id", "skillship_id"], :name => "index_slots_on_event_id_and_skillship_id", :unique => true
  add_index "slots", ["event_id"], :name => "index_slots_on_event_id"

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
