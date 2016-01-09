class AddRemoteDateToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :remote_date, :date
  end
end
