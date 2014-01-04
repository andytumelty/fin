class Account < ActiveRecord::Base
	belongs_to :user
	has_many :transactions, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :user, case_sensitive: false }
end
