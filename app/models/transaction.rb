class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_one :user, :through => :account

  validates :description, presence: true
  validates :amount, presence: true
  validates :amount, numericality: true, if: "!amount.nil?"
  validates :account, presence: true
  validates :category, presence: true

  before_create :generate_order
  #after_commit :update_transaction_balances

  # TODO Split transactions
  
  def self.to_csv
    CSV.generate do |csv|
      csv << ["id", "order", "date", "budget_date","description", "amount", "account_balance", "balance", "account", "category"]
      all.each do |t|
        csv << [t.id, t.order, t.date, t.budget_date, t.description, t.amount, t.account_balance, t.balance, t.account.name, t.category.name]
      end
    end
  end

  def generate_order
    self.order = self.user.transactions.order(order: :desc).first.order + 1
  end

  def update_transaction_balances
    
  end

end