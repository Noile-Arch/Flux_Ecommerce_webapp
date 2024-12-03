class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :title
      t.decimal :price, precision: 10, scale: 2
      t.text :description
      t.string :category
      t.string :image
      t.integer :stock, default: 0
      t.integer :ratingCount, default: 0
      t.decimal :ratingRate, precision: 3, scale: 2, default: 0.0

      t.timestamps
    end
  end
end 