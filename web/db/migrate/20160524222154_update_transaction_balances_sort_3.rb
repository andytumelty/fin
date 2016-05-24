class UpdateTransactionBalancesSort3 < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW transaction_balances;
      ALTER VIEW transaction_with_balances
        RENAME TO transaction_balances;
    SQL
  end
  def down
    # TODO eurgh, this isn't indicative of true up/down migrations, need to compress
    # the view migrations into something true
    execute "DROP VIEW transaction_with_balances;"
  end
end
