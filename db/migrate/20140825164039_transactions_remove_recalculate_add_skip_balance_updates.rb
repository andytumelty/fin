class TransactionsRemoveRecalculateAddSkipBalanceUpdates < ActiveRecord::Migration
  def change
    remove_column :transactions, :recalculate
    add_column :transactions, :skip_balance_update, :boolean
  end
end
