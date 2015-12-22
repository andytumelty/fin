class AddTransactionWithBalanceView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW transaction_with_balances as(
        SELECT
          t.id as transaction_id
          , sum(amount) over(partition by t.account_id order by t.sort, t.id) as account_balance
          , sum(amount) over(partition by a.user_id order by t.sort, t.id) as balance
        FROM transactions t
        JOIN accounts a on t.account_id = a.id
        JOIN categories c on t.category_id = c.id
        ORDER BY a.user_id, t.sort, t.id
      );
    SQL
  end
  def down
    execute "DROP VIEW transaction_with_balances;"
  end
end
