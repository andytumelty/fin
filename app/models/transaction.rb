class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_one :user, :through => :account
  validates :description, presence: true
  validates :amount, presence: true
  validates :amount, numericality: true, if: "!amount.nil?"
  validates :account, presence: true
  validates :category, presence: true
end
