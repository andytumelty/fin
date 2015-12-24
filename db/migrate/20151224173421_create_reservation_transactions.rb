class CreateReservationTransactions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW reservation_transactions as (
        select
        greatest(b_t.budget_id, b_r.budget_id) as budget_id
        , b_r.reservation_id
        , b_t.transaction_id
        --, sum(b_t.amount) as balance
        from (
          select
          b.id as budget_id
          , transaction_id
          , category_id
          , amount
          from budgets b
          left join
          (
            select
            t.id as transaction_id
            , t.budget_date
            , t.amount
            , c.id as category_id
            , c.user_id
            from transactions t
            join categories c on t.category_id = c.id
          ) t_c
          on
          t_c.budget_date between b.start_date
          and b.end_date and b.user_id = t_c.user_id
        ) b_t
        full outer join (
          select
          b.id as budget_id
          , r.id as reservation_id
          , r.category_id
          from budgets b
          join reservations r
          on r.budget_id = b.id
        ) b_r
        on b_r.budget_id = b_t.budget_id
        and (b_r.category_id = b_t.category_id or b_t.category_id is null)
        --group by greatest(b_t.budget_id, b_r.budget_id), reservation_id
      );
    SQL
  end
  def down
    execute "drop view reservation_transactions;"
  end
end
