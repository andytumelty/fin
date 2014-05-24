class Reservation < ActiveRecord::Base
  belongs_to :budget
  #belongs_to :category

  validates :category_id, uniqueness: {scope: :budget, case_sensitive: false}

  after_commit :trigger_budget_calcs
  
  def trigger_budget_calcs
    puts "%%%%% reservation.rb : trigger_budget_calcs"
    self.budget.update_reservation_balances
    self.budget.update_budget_balance
  end
end