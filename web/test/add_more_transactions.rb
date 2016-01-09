u = User.all
t_to_add = (5000..10000)

rand(t_to_add).times do |n|
  Transaction.transaction do
    Transaction.create(
      date: Time.now - rand(1..30).days,
      description: "test_transaction",
      amount: rand(-100.00..100.00).round(2),
      account: u.sample.accounts.sample,
      category: u.sample.categories.sample
    )
  end
end
