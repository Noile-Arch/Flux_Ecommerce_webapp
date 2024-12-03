class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  before_save :reduce_stock

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }

  private

  def reduce_stock
    if product.stock >= quantity
      product.update(stock: product.stock - quantity)
    else
      errors.add(:product, 'is out of stock')
      throw(:abort)
    end
  end
end
