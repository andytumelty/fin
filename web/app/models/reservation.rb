class Reservation < ActiveRecord::Base
  belongs_to :budget
  belongs_to :category
  has_one :user, :through => :budget
  has_many :reservation_transactions
  has_many :related_transactions, class_name: "Transaction", :through => :reservation_transactions

  validates :category_id, uniqueness: {scope: :budget, case_sensitive: false}
  
  def balance
    return self.related_transactions.sum("amount")
  end

  def transactions
    budget_transactions = self.user.transactions.where(budget_date: (self.budget.start_date..self.budget.end_date))
    # TODO make category_id for everything_else reservation 0 instead of nil
    if self.category_id.nil?
      transactions = budget_transactions.where.not(category_id: self.budget.reservations.map { |r| r.category_id })
    else
      transactions = budget_transactions.where(category_id: self.category_id)
    end
    return transactions
  end
end
