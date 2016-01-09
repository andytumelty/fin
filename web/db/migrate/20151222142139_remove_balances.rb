class RemoveBalances < ActiveRecord::Migration
  def change
    remove_column :budgets, :balance
    remove_column :reservations, :balance
    remove_column :transactions, :balance
    remove_column :transactions, :account_balance
    remove_column :transactions, :update_balance
  end
end
