class ReservationBalance < ActiveRecord::Base
  after_initialize :readonly!

  belongs_to :reservation, foreign_key: "reservation_id", class_name: "Reservation"
end
