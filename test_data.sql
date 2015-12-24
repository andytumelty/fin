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

-- TODO make this representative
CREATE TABLE reservations (
  id int primary key
  , budget_id int references budgets(id)
  , category_id int references categories(id)
  , amount int
  , ignored BOOLEAN default false
);

INSERT INTO reservations
  (id, budget_id, category_id, amount, ignored)
VALUES
  (1,  1, 1, 10, FALSE),
  (2,  1, 2, 10, FALSE),
  (3,  3, 3, 10, FALSE),
  (4,  3, 4, 10, FALSE)
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
  (10, 2, 1, '2015-12-06', '2015-11-06', 'Test 10', -21)
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
create view reservation_transaction as(
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
