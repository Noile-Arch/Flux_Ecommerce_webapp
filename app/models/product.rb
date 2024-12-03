class Product < ApplicationRecord
  self.table_name = "Product"
  self.primary_key = "id" # UUID primary key

  has_many :cart_items
  has_many :order_items
  
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
