class RenameTransactionOrderToSort < ActiveRecord::Migration
  def change
    rename_column :transactions, :order, :sort
  end
end
