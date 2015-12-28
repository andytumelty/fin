def add_user(num_accounts, num_categories, num_transactions, t_dates)
  u = User.new()
  user_id = User.count + 1
  u.username = "user_#{user_id}"
  u.password = "user_#{user_id}"
  u.password_confirmation = "user_#{user_id}"
  u.save

  num_accounts.times do |n|
    Account.create(name: "account_#{n}_#{u.id}", user: u)
  end

  num_categories.times do |n|
    Category.create(name: "category_#{n}_#{u.id}", user: u)
  end

  num_transactions.times do |n|
    Transaction.create(
      date: rand(t_dates),
      description: "test_transaction",
      amount: rand(-100.00..100.00).round(2),
      account: u.accounts.sample,
      category: u.categories.sample
    )
  end
end
