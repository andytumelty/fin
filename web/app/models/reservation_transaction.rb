class ReservationTransaction < ActiveRecord::Base
  self.table_name = "reservations_transactions"

  belongs_to :reservation
  belongs_to :related_transaction, class_name: "Transaction", foreign_key: "transaction_id"
end
