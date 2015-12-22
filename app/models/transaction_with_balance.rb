class TransactionWithBalance < ActiveRecord::Base
  after_initialize :readonly!

  belongs_to :parent_transaction, foreign_key: "transaction_id", class_name: "Transaction"
end
