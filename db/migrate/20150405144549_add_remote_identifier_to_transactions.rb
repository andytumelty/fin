class AddRemoteIdentifierToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :remote_identifier, :string
  end
end
