class Budget < ActiveRecord::Base
  belongs_to :user
  has_many :reservations, dependent: :destroy
end
