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
  after_commit :update_transaction_balances
  
  def self.to_csv
    CSV.generate do |csv|
      csv << ["id", "order", "date", "budget_date","description", "amount", "account_balance", "balance", "account", "category"]
      all.each do |t|
        csv << [t.id, t.order, t.date, t.budget_date, t.description, t.amount, t.account_balance, t.balance, t.account.name, t.category.name]
      end
    end
  end

  def generate_order
    last_transaction_on_date = self.user.transactions.where(date: self.date).order(order: :asc).last
    self.order = 1
    if last_transaction_on_date.present?
      self.order += last_transaction_on_date.order
    end
  end

  def update_transaction_balances # TODO update balances only if date, amount or account changes
    if self.date_was.nil?
      date = self.date
      old_date = date
    else
      date = [self.date, self.date_was].min
    end
    transactions = self.user.transactions.where("date >= :date", date: date).order(date: :asc, order: :asc)
    last_transaction = self.user.transactions.where("date < :date", date: date).order(date: :asc, order: :asc).last
    if last_transaction.present?
      balance = last_transaction.balance
    else
      balance = 0
    end
    account_balances = Hash.new
    self.user.accounts.each do |account|
      last_account_transaction = account.transactions.where("date < :date", date: date).order(date: :asc, order: :asc).last
      if last_account_transaction.present?
        account_balance = last_account_transaction.account_balance
      else
        account_balance = 0
      end
      account_balances[account.name] = account_balance
    end
    transactions.each do |transaction|
      balance += transaction.amount
      transaction.update_column('balance', balance)
      account_balances[transaction.account.name] += transaction.amount
      transaction.update_column('account_balance', account_balances[transaction.account.name])
    end
    budgets = self.user.budgets.where("(start_date <= :budget_date AND end_date >= :budget_date) OR (start_date <= :old_budget_date AND end_date >= :old_budget_date)", budget_date: date, old_budget_date: old_date)
    budgets.each do |budget|
      budget.update_reservation_balances
      budget.update_budget_balance
    end
  end

end