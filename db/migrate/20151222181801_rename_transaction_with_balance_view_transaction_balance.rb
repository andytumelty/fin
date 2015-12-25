class RenameTransactionWithBalanceViewTransactionBalance < ActiveRecord::Migration
  def up
    execute "
      ALTER VIEW
        transaction_with_balances
        RENAME TO 
        transaction_balances
    ;"
  end

  def down
    execute "
      ALTER VIEW
        transaction_balances
        RENAME TO 
        transaction_with_balances
    ;"
  end
end
