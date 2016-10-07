class RemoveRemoteAcccountIdentifierFromTransaction < ActiveRecord::Migration
  def change
    remove_column :transactions, :remote_identifier
  end
end
