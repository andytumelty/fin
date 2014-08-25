class RenameTransactionSkipBalanceUpdateToUpdateBalance < ActiveRecord::Migration
  def change
    rename_column :transactions, :skip_balance_update, :update_balance
  end
end
