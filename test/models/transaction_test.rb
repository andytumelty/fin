require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should not save without description" do
    transaction = Transaction.new
    assert_not transaction.save
  end
end
