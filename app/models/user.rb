class User < ApplicationRecord
  has_one :cart, dependent: :destroy
  has_many :orders
  # Validations for email, password, and username
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true 
  validates :password, presence: true, length: { minimum: 6 }

  has_secure_password

  def admin?
    is_admin
  end
end
