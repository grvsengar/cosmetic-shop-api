class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :razorpay_order_id
      t.string :razorpay_payment_id
      t.text :address, null: false

      t.timestamps
    end

    add_index :orders, :razorpay_order_id, unique: true
    add_index :orders, :razorpay_payment_id, unique: true
  end
end
