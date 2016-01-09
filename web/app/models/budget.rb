class Budget < ActiveRecord::Base
  # TODO validate attributes
  belongs_to :user
  has_many :reservations, dependent: :delete_all
  
  # FIXME should this validate as dates?
  validates :start_date, presence: true
  validates :end_date, presence: true

  before_create :apply_name
  after_create :copy_previous_reservations

  # TODO Should this logic sit in the model or database as a view?
  def balance
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
    return balance
  end

  def apply_name
    if self.name.blank?
      self.name = self.start_date.to_s + " to " + self.end_date.to_s
    end
  end

  def copy_previous_reservations
    # logger.debug { 'budget.rb : copy_previous_reservations' }
    # If this is the first budget, set up everything else reservation
    # else, propagate previous reservations
    if self.user.budgets.count > 1
      # logger.debug { 'self.user.budgets.count > 1' }
      prev_budget = self.user.budgets.where.not(id: self.id).order(id: :asc).last
      prev_budget.reservations.order(category_id: :desc).each do |prev_reservation|
        Reservation.create(
          budget: self,
          category_id: prev_reservation.category_id,
          amount: prev_reservation.amount,
          ignored: prev_reservation.ignored
        )
      end
    else
      Reservation.create(budget: self, amount: 0)
    end
  end
end
