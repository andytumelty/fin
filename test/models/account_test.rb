require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "should not save accout without name" do
    account = Account.new(user: users(:user_1))
    assert_not account.save
  end

  test "should not save acccount with duplicate name for same user" do
    u1 = users(:user_1)
    u2 = users(:user_2)
    a1 = Account.new(user: u1, name: "account_test_name_uniqueness")
    assert a1.save
    a2 = Account.new(user: u2, name: "account_test_name_uniqueness")
    assert a2.save
    a3 = Account.new(user: u1, name: "account_test_name_uniqueness")
    assert_not a3.save
  end

  test "should delete related transactions when deleting account" do
    u = users(:user_1)
    a = Account.create(user: u, name: "account_test_transaction_delete")
    t = Transaction.new(
      date: Date.parse('2015-01-01'),
      description: "account_test_transaction_delete",
      category: categories(:category_1_1),
      account: a,
      amount: 10
    )
    t.save
    ts = a.transactions
    assert a.destroy
    ts.reload
    assert ts.empty?
  end
end
