class Category < ActiveRecord::Base
  belongs_to :user
  has_many :transactions
  has_many :reservations

  validates :name, presence: true, uniqueness: { scope: :user, case_sensitive: false }

  after_destroy :reassign_transactions, :delete_reservations

  def reassign_transactions
    puts "%%%%% category.rb : reassign_transactions"
    transactions = self.user.transactions.where(category: self)
    transactions.update_all(category: self.user.categories.where(name: "unassigned").first)
  end

  def delete_reservations
    puts "%%%%% category.rb : delete_reservations"
    reservations.where(category_id: self.id).delete
  end
  
  # TODO protect unassigned from edit and delete
end
