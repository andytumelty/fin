class Reservation < ActiveRecord::Base
  belongs_to :budget
  #belongs_to :category

  validates :category_id, uniqueness: {scope: :budget, case_sensitive: false}

  # TODO after delete, update budget reseervations and budget balance
end