class Account < ActiveRecord::Base
	belongs_to :user
	has_many :transactions, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :user, case_sensitive: false }

  after_destroy :trigger_balance_calcs

  def trigger_balance_calcs
    puts "%%%%% account.rb : trigger_balance_calcs"
    self.user.transactions.order(date: :asc, order: :asc).first.update_transaction_balances
  end

end
