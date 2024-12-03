class AddMissingColumnsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :status, :string, default: 'pending', null: false unless column_exists?(:orders, :status)
    add_column :orders, :total_amount, :decimal, precision: 10, scale: 2, default: 0.0, null: false unless column_exists?(:orders, :total_amount)
  end
end
