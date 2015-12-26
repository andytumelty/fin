class Account < ActiveRecord::Base
	belongs_to :user, inverse_of: :accounts
	has_many :transactions, dependent: :destroy, inverse_of: :account
  validates :name, presence: true, uniqueness: { scope: :user, case_sensitive: false }
  has_one :remote_account

end
