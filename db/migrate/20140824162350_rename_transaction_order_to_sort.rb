class RenameTransactionOrderToSort < ActiveRecord::Migration
  def change
    rename_column :transactions, :order, :rank
  end
end
