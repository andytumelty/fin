class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true
  validates :username, uniqueness: {case_sensitive: :false}

  has_many :accounts, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :transactions, :through => :accounts, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :reservations, :through => :budgets
end
