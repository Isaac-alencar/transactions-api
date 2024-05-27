# frozen_string_literal: true

class CreateTransaction < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :transaction_id, null: false
      t.string :card_holder, null: false
      t.string :card_number, null: false
      t.string :card_expiration_date, null: false
      t.integer :card_security_code, null: false, limit: 3
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :transactions, :transaction_id, unique: true
  end
end
