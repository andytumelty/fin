class Budget < ActiveRecord::Base
  belongs_to :user
  has_many :reservations, dependent: :destroy

  after_create :copy_previous_reservations, :update_reservation_balances, :update_budget_balance
  after_update :update_reservation_balances, :update_budget_balance

  def update_reservation_balances
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
  end

  def update_budget_balance
    balance = 0
    self.reservations.each do |reservation|
      if !reservation.ignored
        if reservation.amount == 0
          balance += reservation.balance
        elsif reservation.amount > 0
          balance += max(reservation.balance, reservation.amount)
        else
          balance += min(reservation.balance, reservation.amount)
        end
      end
    end
    self.update_column('balance', balance)
  end

  def copy_previous_reservations
    if Budget.where(user: self.user).count > 1
      Budget.where(user: self.user).order(start_date: :desc).first.reservations.each do |prev_reservation|
        Reservation.create(budget: self, category_id: prev_reservation.category_id, amount: prev_reservation.amount, ignored: prev_reservation.ignored)
      end
    else
      Reservation.create(budget: self, amount: 0)
    end
  end
end
