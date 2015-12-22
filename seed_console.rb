num_users = 10
a_per_u = (1..5)
c_per_u = (0..10)
t_per_u = (10..1000)

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
      date: Time.now - rand(1..30).days,
      description: "transaction_#{n}",
      amount: rand(-100.00..100.00).round(2),
      account: a.sample,
      category: c.sample
    )
  end
end
