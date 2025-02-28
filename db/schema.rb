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

ActiveRecord::Schema[7.1].define(version: 20_240_527_161_428) do
  create_table 'transactions', force: :cascade do |t|
    t.string 'transaction_id', null: false
    t.string 'card_holder', null: false
    t.string 'card_number', null: false
    t.string 'card_expiration_date', null: false
    t.integer 'card_security_code', limit: 3, null: false
    t.decimal 'amount', precision: 10, scale: 2, null: false
    t.integer 'status', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'user_id'
    t.index ['transaction_id'], name: 'index_transactions_on_transaction_id', unique: true
    t.index ['user_id'], name: 'index_transactions_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'transactions', 'users'
end
