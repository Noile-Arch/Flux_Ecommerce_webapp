class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.uuid :product_id, null: false
      t.integer :quantity
      t.decimal :price, precision: 10, scale: 2
      
      t.timestamps
    end

    add_foreign_key :order_items, :Product, column: :product_id
    add_index :order_items, :product_id
  end
end
