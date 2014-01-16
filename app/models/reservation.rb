class Reservation < ActiveRecord::Base
  belongs_to :budget
  #belongs_to :category

  validates :category_id, uniqueness: {scope: :budget, case_sensitive: false}

  # TODO after delete, update budget reservations and budget balance
  # TODO after create, update budget reservations and budget balance (can this be wrapped with above in after commit?)
end