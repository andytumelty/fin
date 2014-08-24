class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_one :user, :through => :account

  validates :description, presence: true
  validates :amount, presence: true
  validates :amount, numericality: true, if: "!amount.nil?"
  validates :account, presence: true
  validates :category, presence: true

  before_create :generate_order, prepend: true
  before_create :update_transaction_balances
  after_update :update_transaction_balances
  after_destroy :update_transaction_balances

  # TODO Split transactions
  
  def self.to_csv
    CSV.generate do |csv|
      csv << ["id", "sort", "date", "budget_date","description", "amount", "account_balance", "balance", "account", "category"]
      all.each do |t|
        csv << [t.id, t.sort, t.date, t.budget_date, t.description, t.amount, t.account_balance, t.balance, t.account.name, t.category.name]
      end
    end
  end

  def generate_order
    self.sort = self.user.transactions.order(sort: :desc).first.sort + 1
  end

  def update_transaction_balances

  end

end