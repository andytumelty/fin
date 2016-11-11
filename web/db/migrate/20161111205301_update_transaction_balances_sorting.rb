class UpdateTransactionBalancesSorting < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW transaction_balances as(
        SELECT
          t.id as transaction_id
          , sum(amount) over(partition by t.account_id order by t.date, t.id) as account_balance
          , sum(amount) over(partition by a.user_id order by t.date, t.id) as balance
        FROM transactions t
        JOIN accounts a on t.account_id = a.id
        JOIN categories c on t.category_id = c.id
        ORDER BY a.user_id, t.date, t.description, t.id
      );
    SQL
  end
  def down
    execute <<-SQL
      CREATE OR REPLACE VIEW transaction_balances as(
        SELECT
          t.id as transaction_id
          , sum(amount) over(partition by t.account_id order by t.date, t.description, t.id) as account_balance
          , sum(amount) over(partition by a.user_id order by t.date, t.description, t.id) as balance
        FROM transactions t
        JOIN accounts a on t.account_id = a.id
        JOIN categories c on t.category_id = c.id
        ORDER BY a.user_id, t.date, t.description, t.id
      );
    SQL
  end
end
