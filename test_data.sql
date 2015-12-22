-- http://sqlfiddle.com/#!15/7de01/1

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
  (4, 2, 'Test 4')
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
  (2, 2, 'November 2015', date('2015-11-01'), date('2015-11-30')),
  (3, 1, 'December 2015', date('2015-12-01'), date('2015-12-30')),
  (4, 2, 'December 2015', date('2015-12-01'), date('2015-12-30'))
;

-- TODO make this representative
CREATE TABLE reservations (
  id int primary key
  , budget_id int references budgets(id)
  , category_id int references categories(id)
);

INSERT INTO reservations
  (id, budget_id, category_id)
VALUES
  (1, 1, 1),
  (2, 1, 2),
  (3, 3, 1),
  (4, 3, 2),
  (5, 2, 3),
  (6, 2, 4),
  (7, 4, 3),
  (8, 4, 4)
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
  (7 , 3, 4, '2015-12-05', '2015-11-05', 'Test 7' ,  50),
  (8 , 1, 2, '2015-12-05', '2015-11-05', 'Test 8' ,  16),
  (9 , 2, 2, '2015-12-05', '2015-11-05', 'Test 9' ,  18),
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

CREATE VIEW reservation_view as(
  select
    r.*
    --, to_char(b.start_date, 'YYYY-MM-DD') as start_date
    --, to_char(b.end_date, 'YYYY-MM-DD') as end_date
    --, c.name as category_name
    , sum(t.amount)
  from reservations r
  join budgets b on b.id = r.budget_id
  join categories c on c.id = r.category_id
  join transactions t on r.category_id = t.category_id
  where t.budget_date between b.start_date and b.end_date
  group by r.id, r.budget_id, r.category_id --, b.start_date, b.end_date, c.name
);

-- create budget view showing budget balance

-- DATA VIEW
select
  id
  , to_char(date, 'YYYY-MM-DD') as date
  , to_char(budget_date, 'YYYY-MM-DD') as budget_date
  , description
  , user_id
  , account_name
  , category_name
  , amount
  , account_balance
  , balance
from transaction_view
where user_id = 1
;

select
  *
from reservation_view
where budget_id = 1
;
