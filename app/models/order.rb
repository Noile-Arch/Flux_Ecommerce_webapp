class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :status, inclusion: { in: %w[pending processing completed cancelled] }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_default_status

  private

  def set_default_status
    self.status ||= 'pending'
  end
end
