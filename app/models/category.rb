class Category < ActiveRecord::Base
  belongs_to :user
  has_many :transactions
  validates :name, presence: true, uniqueness: { scope: :user, case_sensitive: false }
end
