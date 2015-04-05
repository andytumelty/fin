class AddSyncFromDateToRemoteAccounts < ActiveRecord::Migration
  def change
    add_column :remote_accounts, :sync_from, :date
  end
end
