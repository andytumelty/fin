class Category < ActiveRecord::Base
  belongs_to :user
  has_many :transactions
  has_many :reservations

  validates :name, presence: true, uniqueness: { scope: :user, case_sensitive: false }

  before_destroy :confirm_not_unassigned
  after_destroy :reassign_transactions

  def reassign_transactions
    transactions = self.user.transactions.where(category: self)
    transactions.update_all(category_id: self.user.categories.where(name: "unassigned").first.id)
  end

  def confirm_not_unassigned
    # FIXME is there a better way of checking rather than checking name?
    if self.name == "unassigned"
      return false
    end
  end
end
