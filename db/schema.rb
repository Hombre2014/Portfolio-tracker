# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_08_03_210354) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "timescaledb"

  create_table "portfolios", force: :cascade do |t|
    t.string "name"
    t.string "acc_number"
    t.decimal "cash"
    t.date "opened_date"
    t.decimal "realized_profit_loss"
    t.decimal "transactions_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "positions", force: :cascade do |t|
    t.date "open_date"
    t.string "symbol"
    t.decimal "quantity"
    t.decimal "cost_per_share"
    t.decimal "commission_and_fee"
    t.decimal "realized_profit_loss"
    t.bigint "portfolio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id"], name: "index_positions_on_portfolio_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "ticker"
    t.integer "transaction_id"
    t.decimal "realized_profit_loss"
    t.decimal "commission_and_fee"
    t.decimal "shares_owned"
    t.bigint "portfolio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id"], name: "index_stocks_on_portfolio_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "tr_type"
    t.date "trade_date"
    t.string "symbol"
    t.integer "quantity"
    t.decimal "price"
    t.decimal "commission"
    t.decimal "fee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "portfolio_id", null: false
    t.index ["portfolio_id"], name: "index_transactions_on_portfolio_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "portfolios", "users"
  add_foreign_key "positions", "portfolios"
  add_foreign_key "stocks", "portfolios"
  add_foreign_key "transactions", "portfolios"
end
