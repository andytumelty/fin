class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_one :user, :through => :account
  validates :description, presence: true
  validates :amount, presence: true
  validates :amount, numericality: true, if: "!amount.nil?"
  validates :account, presence: true
  validates :category, presence: true

  def self.to_csv
    CSV.generate do |csv|
      csv << ["id", "date", "description", "amount", "account", "category"]
      all.each do |t|
        csv << [t.id, t.date, t.description, t.amount, t.account.name, t.category.name]
      end
    end
  end
end
