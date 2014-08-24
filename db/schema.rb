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

ActiveRecord::Schema.define(version: 20140824162350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "budgets", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "balance",    precision: 19, scale: 4
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "budgets", ["user_id"], name: "index_budgets_on_user_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["user_id"], name: "index_categories_on_user_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
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

  create_table "reservations", force: true do |t|
    t.integer  "category_id"
    t.decimal  "amount",      precision: 19, scale: 4
    t.decimal  "balance",     precision: 19, scale: 4
    t.boolean  "ignored",                              default: false
    t.integer  "budget_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "recalculate"
  end

  add_index "reservations", ["budget_id"], name: "index_reservations_on_budget_id", using: :btree
  add_index "reservations", ["category_id"], name: "index_reservations_on_category_id", using: :btree

  create_table "transactions", force: true do |t|
    t.date     "date"
    t.string   "description"
    t.decimal  "amount",          precision: 19, scale: 4
    t.integer  "account_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "budget_date"
    t.decimal  "balance",         precision: 19, scale: 4
    t.decimal  "account_balance", precision: 19, scale: 4
    t.float    "rank"
    t.boolean  "recalculate"
  end

  add_index "transactions", ["account_id"], name: "index_transactions_on_account_id", using: :btree
  add_index "transactions", ["category_id"], name: "index_transactions_on_category_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username",         null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
