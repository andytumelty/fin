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

  test "should delete dependents when deleting account" do
    u = users(:user_1)
    a = Account.create(user: u, name: "account_test_transaction_delete")
    Transaction.create(
      date: Date.parse('2015-01-01'),
      description: "account_test_transaction_delete",
      category: categories(:category_1_1),
      account: a,
      amount: 10
    )
    ra = RemoteAccount.create(
      title: "account_test_remote_account_delete",
      inverse_values: false,
      user_credential: "user_1",
      remote_account_identifier: "1234",
      account: a,
      remote_account_type: RemoteAccountType.all.sample,
      sync_from: Date.today
    )
    assert a.destroy, "account not successfully destroyed"
    assert_empty a.transactions, "transactions not destroyed with account"
    assert_not RemoteAccount.exists?(ra.id), "remote account not destroyed with account"
  end
end
