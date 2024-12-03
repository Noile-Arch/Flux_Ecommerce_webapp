class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, foreign_key: 'product_id', primary_key: 'id'
  
  validates :quantity, presence: true
  validates :price, presence: true
end
