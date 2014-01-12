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
  after_save :update_transaction_balances
  
  def self.to_csv
    CSV.generate do |csv|
      csv << ["id", "order", "date", "description", "amount", "account_balance", "balance", "account", "category"]
      all.each do |t|
        csv << [t.id, t.order, t.date, t.description, t.amount, t.account_balance, t.balance, t.account.name, t.category.name]
      end
    end
  end

  def generate_order
    last_transaction_on_date = self.user.transactions.where(date: self.date).order(order: :asc).last
    self.order = 1
    if !last_transaction_on_date.nil?
      self.order += last_transaction_on_date.order
    end
  end

  def update_transaction_balances
    if self.date_was.nil?
      date = self.date
    else
      date = [self.date, self.date_was].min
    end
    puts "Looking for txs after #{date}"
    transactions = self.user.transactions.where("date >= :date", date: date).order(date: :asc, order: :asc)
    puts "I'll have to update #{transactions.count} transactions"
    last_transaction = self.user.transactions.where("date < :date", date: date).order(date: :asc, order: :asc).last
    if !last_transaction.nil?
      balance = last_transaction.balance
    else
      balance = 0
    end
    account_balances = Hash.new
    self.user.accounts.each do |account|
      last_account_transaction = account.transactions.where("date < :date", date: date).order(date: :asc, order: :asc).last
      if !last_account_transaction.nil?
        account_balance = last_account_transaction.account_balance
      else
        account_balance = 0
      end
      account_balances[account.name] = account_balance
    end
    transactions.each do |transaction|
      puts "%%%%%%%%%% update tx #{transaction.id} (date: #{transaction.date}, desc: #{transaction.description}, amount: #{transaction.amount}) %%%%%%%%"
      balance += transaction.amount
      transaction.update_column('balance', balance)
      account_balances[transaction.account.name] += transaction.amount
      transaction.update_column('account_balance', account_balances[transaction.account.name])
    end
  end

end