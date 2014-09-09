class Budget < ActiveRecord::Base
  belongs_to :user
  has_many :reservations, dependent: :destroy

  after_create :copy_previous_reservations, :update_reservation_balances, :update_budget_balance
  after_update :update_reservation_balances, :update_budget_balance

  def update_reservation_balances
    # OPTIMIZE: Is it quicker to grab all transactions like this or do a SQL sum for each reservation as in Reservation.update_reservation_balance
    # logger.debug { 'budget.rb : update_reservation_balances' }
    transactions = self.user.transactions.where(budget_date: (self.start_date..self.end_date))
    reservations = self.reservations
    reservations.update_all(balance: 0)
    transactions.each do |transaction|
      reservation = reservations.where(category_id: transaction.category.id).first
      if reservation.blank?
        reservation = reservations.where(category_id: nil).first
      end
      reservation.update_column('balance', reservation.balance + transaction.amount)
    end
    self.reservations.reload
  end

  def update_budget_balance
    # logger.debug 'budget.rb : update_budget_balance' }
    balance = 0
    self.reservations.each do |reservation|
      if !reservation.ignored
        if reservation.amount == 0
          balance += reservation.balance
        elsif reservation.amount > 0
          balance += [reservation.balance, reservation.amount].max
        else
          balance += [reservation.balance, reservation.amount].min
        end
      end
    end
    self.update_column('balance', balance)
  end

  def copy_previous_reservations
    # logger.debug { 'budget.rb : copy_previous_reservations' }
    if self.user.budgets.count > 1
      # logger.debug { 'self.user.budgets.count > 1' }
      prev_budget = self.user.budgets.where.not(id: self.id).order(start_date: :asc).last
      prev_budget.reservations.each do |prev_reservation|
        Reservation.create(budget: self, category_id: prev_reservation.category_id, amount: prev_reservation.amount, ignored: prev_reservation.ignored)
      end
    else
      Reservation.create(budget: self, amount: 0)
    end
  end
end
