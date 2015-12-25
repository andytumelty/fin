class Reservation < ActiveRecord::Base
  belongs_to :budget
  belongs_to :category
  has_one :user, :through => :budget
  has_and_belongs_to_many :related_transactions, class_name: "Transaction", :dependent => :restrict_with_error

  validates :category_id, uniqueness: {scope: :budget, case_sensitive: false}
  
  def balance
    return self.related_transactions.sum("amount")
  end
end
