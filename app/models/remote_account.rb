class RemoteAccount < ActiveRecord::Base
  belongs_to :account
  belongs_to :remote_account_type
end
