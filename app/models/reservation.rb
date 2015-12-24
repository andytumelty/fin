class Reservation < ActiveRecord::Base
  belongs_to :budget
  belongs_to :category
  has_one :user, :through => :budget
  has_and_belongs_to_many :related_transactions, class_name: "Transaction"
  #has_one :reservation_balace, foreign_key: "reservation_id"
  #delegate :balance, to: :reservation_balance

  validates :category_id, uniqueness: {scope: :budget, case_sensitive: false}

  #after_create :trigger_budget_calcs
  
  #def trigger_budget_calcs
  #  # logger.debug { 'reservation.rb : trigger_budget_calcs' }
  #  # logger.debug { self.inspect }
  #  self.update_reservation_balance
  #  self.budget.reservations.where(category_id: nil).first.update_reservation_balance unless self.category_id.nil?
  #  self.budget.update_budget_balance
  #end

  #def update_reservation_balance
  #  # logger.debug { 'reservation.rb : update_reservation_balance' }
  #  if self.category_id.nil? # everything else
  #    categories = self.budget.reservations.where.not(category_id: nil).select('category_id').collect{|c| c.category_id}
  #    # OPTIMIZE select only what you need!
  #    self.balance = self.user.transactions.where(date: self.budget.start_date..self.budget.end_date).where.not(category_id: categories).sum(:amount)
  #  else
  #    self.balance = self.user.transactions.where(date: self.budget.start_date..self.budget.end_date).where(category_id: self.category_id).sum(:amount)
  #  end
  #  self.save
  #end
end
