class CreateReservationBalances < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW reservation_balances as(
        select
          r.id as reservation_id
          , sum(t.amount)
        from reservations r
        join budgets b on b.id = r.budget_id
        join categories c on c.id = r.category_id
        join transactions t on r.category_id = t.category_id
        where t.budget_date between b.start_date and b.end_date
        group by r.id
      );
    SQL
  end
  def down
    execute "DROP VIEW reservation_balances;"
  end
end
