class CreateReservationTransactions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW reservation_transactions as (
        with reservation_transactions as (
          select
            t.id as transaction_id
            , b.id as budget_id
            , b.start_date as budget_start_date
            , b.end_date as budget_end_date
            , r.id as reservation_id
            , r.category_id as category_id
            , b.user_id as user_id
          from budgets b
          join reservations r
            on b.id = r.budget_id
          left join transactions t
            on t.budget_date between b.start_date and b.end_date
            and t.category_id = r.category_id
        ) select 
          rt.budget_id
          , rt.reservation_id
          , coalesce(rt.transaction_id, t_2.transaction_id) as transaction_id
        from reservation_transactions rt
        left join (
          select
            t.id as transaction_id
            , t.budget_date
            , c.user_id
          from transactions t
          join categories c on t.category_id = c.id
          where t.id not in (
            select transaction_id
            from reservation_transactions
            where transaction_id is not null
          )
        ) t_2
          on t_2.budget_date between rt.budget_start_date and rt.budget_end_date
          and t_2.user_id = rt.user_id
          and rt.category_id is null
        --order by 1,2,3
      );
    SQL
  end
  def down
    execute "drop view reservation_transactions;"
  end
end
