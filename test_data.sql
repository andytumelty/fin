CREATE TABLE users (
  id int primary key
  , email varchar(6)
);

INSERT INTO users
  (id, email)
VALUES
  (1, '1@test'),
  (2, '2@test')
;

CREATE TABLE accounts (
  id int primary key
  , user_id int references users(id)
  , name varchar(6)
);

INSERT INTO accounts
  (id, user_id, name)
VALUES
  (1, 1, 'Test 1'),
  (2, 1, 'Test 2'),
  (3, 2, 'Test 3')
;

CREATE TABLE categories (
  id int primary key
  , user_id int references users(id)
  , name varchar(6)
);

INSERT INTO categories
  (id, user_id, name)
VALUES
  (1, 1, 'Test 1'),
  (2, 1, 'Test 2'),
  (3, 2, 'Test 3'),
  (4, 2, 'Test 4'),
  (5, 1, 'Test 5')
;

CREATE TABLE budgets (
  id int primary key
  , user_id int references users(id)
  , name varchar(13)
  , start_date date
  , end_date date
);

INSERT INTO budgets
  (id, user_id, name, start_date, end_date)
VALUES
  (1, 1, 'November 2015', date('2015-11-01'), date('2015-11-30')),
  (2, 1, 'January 2016', date('2016-01-01'), date('2016-01-31')),
  (3, 2, 'January 2016', date('2016-01-01'), date('2016-01-31')),
  (4, 2, 'November 2015', date('2015-11-01'), date('2015-11-30'))
;

CREATE TABLE reservations (
  id int primary key
  , budget_id int references budgets(id)
  , category_id int --references categories(id)
  , amount int
  , ignored BOOLEAN default false
);

INSERT INTO reservations
  (id, budget_id, category_id, amount, ignored)
VALUES
  (1, 1, null, 10,  FALSE),
  (2, 1, 2  , 10,  FALSE),
  (3, 2, null, 10,  FALSE),
  (4, 3, null, 10,  FALSE),
  (5, 3, 4  , 10,  TRUE ),
  (6, 4, null, 10,  FALSE)
;

CREATE TABLE transactions (
  id int primary key
  , account_id int references accounts(id)
  , category_id int references categories(id)
  , date date
  , budget_date date
  , description varchar(7)
  , amount int
);

INSERT INTO transactions
  (id, account_id, category_id, date, budget_date, description, amount)
VALUES
  (1 , 1, 2, '2015-12-01', '2015-12-01', 'Test 1' ,  10),
  (2 , 2, 2, '2015-12-01', '2015-12-01', 'Test 2' , -10),
  (3 , 1, 1, '2015-12-02', '2015-12-02', 'Test 3' ,  12),
  (4 , 3, 3, '2015-12-02', '2015-12-02', 'Test 4' , -24),
  (5 , 1, 1, '2015-12-02', '2015-12-02', 'Test 5' ,  50),
  (6 , 2, 1, '2015-12-04', '2015-11-04', 'Test 6' ,  10),
  (7 , 3, 3, '2015-12-05', '2015-11-05', 'Test 7' ,  50),
  (8 , 1, 5, '2015-12-05', '2015-11-05', 'Test 8' ,  16),
  (9 , 2, 5, '2015-12-05', '2015-11-05', 'Test 9' ,  18),
  (10, 2, 2, '2015-12-06', '2015-11-06', 'Test 10', -21)
;

CREATE VIEW transaction_view as(
  SELECT
    t.*
    , a.name as account_name
    , a.user_id
    , c.name as category_name
    , sum(amount) over(partition by t.account_id order by t.date, t.id) as account_balance
    , sum(amount) over(partition by a.user_id order by t.date, t.id) as balance
  FROM transactions t
  JOIN accounts a on t.account_id = a.id
  JOIN categories c on t.category_id = c.id
  ORDER BY user_id, date, t.id
);

-- They call me the SQL cowboy
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
order by 1,2,3
;
