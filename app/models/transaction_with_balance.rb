class TransactionWithBalance < ActiveRecord::Base
  #belongs_to :transaction
  belongs_to :parent_transaction, foreign_key: "transaction_id", class_name: "Transaction"
  #has_one :category, :through => :transaction
  #has_one :account, :through => :transaction
  #has_one :user, :through => :transaction
end
