class AddColumnsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :budget_date, :date
    add_column :transactions, :balance, :decimal, :precision => 19, :scale => 4
    add_column :transactions, :account_balance, :decimal, :precision => 19, :scale => 4
    add_column :transactions, :order, :float
  end
end
