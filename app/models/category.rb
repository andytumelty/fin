class Category < ActiveRecord::Base
  belongs_to :user
  has_many :transactions
  has_many :reservations

  validates :name, presence: true, uniqueness: { scope: :user, case_sensitive: false }

  # TODO after delete, reassign transactions to unassigned, delete reservations with this category (triggering budget updates)
end
