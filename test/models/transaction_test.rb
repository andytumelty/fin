require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  test "transaction balances should be calculated correctly" do
    t = Transaction.all.sample
    assert_equal t.user.transactions.where("sort <= #{t.sort}").sum("amount"), t.balance
    assert_equal t.account.transactions.where("sort <= #{t.sort}").sum("amount"), t.account_balance
  end

  test "should not save without description" do
    u = User.all.sample
    a = u.accounts.sample
    c = u.categories.sample
    transaction = Transaction.new(
      date: Date.today,
      #description: "test",
      amount: 0,
      account: a,
      category: c
    )
    assert_not transaction.save
  end

  test "should not save without numerical amount" do
    u = User.all.sample
    a = u.accounts.sample
    c = u.categories.sample
    transaction = Transaction.new(
      date: Date.today,
      description: "test",
      #amount: 0,
      account: a,
      category: c
    )
    assert_not transaction.save
    transaction = Transaction.new(
      date: Date.today,
      description: "test",
      amount: "zero",
      account: a,
      category: c
    )
    assert_not transaction.save
  end

  test "should not save without account" do
    u = User.all.sample
    #a = u.accounts.sample
    c = u.categories.sample
    transaction = Transaction.new(
      date: Date.today,
      description: "test",
      amount: 0,
      #account: a,
      category: c
    )
    assert_not transaction.save
  end

  test "should not save without category" do
    u = User.all.sample
    a = u.accounts.sample
    #c = u.categories.sample
    transaction = Transaction.new(
      date: Date.today,
      description: "test",
      amount: 0,
      account: a
      #category: c
    )
    assert_not transaction.save
  end

  test "should populate budget_date when blank" do
    u = User.all.sample
    a = u.accounts.sample
    c = u.categories.sample
    transaction = Transaction.new(
      date: Date.today,
      description: "test",
      amount: 0,
      account: a,
      category: c
    )
    transaction.save
    assert_equal transaction.date, transaction.budget_date
  end

  test "should generate order" do
    u = User.all.sample
    a = u.accounts.sample
    c = u.categories.sample
    transaction = Transaction.new(
      date: Date.today,
      description: "test",
      amount: 0,
      account: a,
      category: c
    )
    transaction.save
    assert_equal transaction.sort, transaction.user.transactions.maximum("sort")
  end
end
