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
  after_create :update_transaction_balances
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
    # TODO Surley this could look a bit nicer? a = b? c : d
    if self.user.transactions.empty?
      self.sort = 1
    else
      self.sort = self.user.transactions.order(sort: :desc).first.sort + 1
    end
  end

  def tx_logger
    @@tx_logger ||= Logger.new("#{Rails.root}/log/tx.log")
  end

  def update_transaction_balances
    if self.id_was.nil? || self.destroyed?
      tx_logger.info "New? #{self.id_was.nil?}, Destroyed? #{self.destroyed?}"
      
      to_update = self.user.transactions.where("sort >= ?", self.sort).order(sort: :asc)
      tx_logger.debug "Gonna update #{to_update.count}"
      
      last_tx = self.user.transactions.where("sort < ?", self.sort).order(sort: :desc).first
      last_account_tx = self.user.transactions.where("sort < ?", self.sort).where(account: self.account).order(sort: :desc).first
      
      balance = last_tx.nil? ? 0 : last_tx.balance
      account_balance = last_account_tx.nil? ? 0 : last_account_tx.account_balance
      tx_logger.debug "Balance: #{balance}, Account Balance: #{account_balance}"
      
      ActiveRecord::Base.transaction do
        to_update.each do |tx|
          balance += tx.amount
          tx.update_columns(balance: balance)
          if tx.account_id == self.account_id
            account_balance += tx.amount
            tx.update_columns(account_balance: account_balance)
          end
        end
      end
    else
      tx_logger.info "Changed? #{self.changes}, #{self.inspect}"
    end
  end

end