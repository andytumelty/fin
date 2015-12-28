class Reservation < ActiveRecord::Base
  belongs_to :budget
  belongs_to :category
  has_one :user, :through => :budget
  has_many :reservation_transactions
  has_many :related_transactions, class_name: "Transaction", :through => :reservation_transactions

  validates :category_id, uniqueness: {scope: :budget, case_sensitive: false}
  
  def balance
    return self.related_transactions.sum("amount")
  end
end
