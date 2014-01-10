class Reservation < ActiveRecord::Base
  belongs_to :budget
  belongs_to :category

  validates :category, uniqueness: true {scope: :budget, message: "There's already a reservation in this budget for that category"}
end
