require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should not save without name" do
    account = Account.new(user: users(:user_1))
    assert_not account.save
  end
end
