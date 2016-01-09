class RemoteAccount < ActiveRecord::Base
  belongs_to :account
  belongs_to :remote_account_type
  has_many :transactions, :through => :account

  validates :title, presence: true
  validates :user_credential, presence: true
  validates :remote_account_identifier, presence: true
  validates :account_id, presence: true
  validates :remote_account_type_id, presence: true
  validates :sync_from, presence: true
end
