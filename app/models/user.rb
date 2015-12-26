class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true
  validates :username, uniqueness: {case_sensitive: :false}

  has_many :accounts, dependent: :destroy, inverse_of: :user
  has_many :categories, inverse_of: :user
  has_many :budgets, dependent: :destroy
  has_many :reservations, :through => :budgets
  has_many :transactions, :through => :accounts
  has_many :remote_accounts, :through => :accounts
  
  after_create :create_unassigned_category
  after_destroy :delete_unassigned_category

  private

  def create_unassigned_category
    Category.create(name: "unassigned", user: self)
  end

  def delete_unassigned_category
    self.categories.where(name: "unassigned").delete_all
  end
end
