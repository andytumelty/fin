# you're using this as a test, move it into the formal test framework and define
# pass/fail criteria
num_users = 2
a_per_u = (1..5)
c_per_u = (0..10)
t_per_u = (10..100)
t_dates = (Time.now - 30.days..Time.now)

u = []
num_users.times do |n|
  u << User.create(
    username: "user_#{n}", 
    password: "user_#{n}",
    password_confirmation: "user_#{n}"
  )
end

u.each do |user|
  a = []
  rand(a_per_u).times do |n|
    a << Account.create(name: "account_#{n}", user: user)
  end

  c = []
  c << Category.create(name: "unassigned", user: user)
  rand(c_per_u).times do |n|
    c << Category.create(name: "category_#{n}", user: user)
  end

  t = []
  rand(t_per_u).times do |n|
    t << Transaction.create(
      date: rand(t_dates),
      description: "test_transaction",
      amount: rand(-100.00..100.00).round(2),
      account: a.sample,
      category: c.sample
    )
  end

end
