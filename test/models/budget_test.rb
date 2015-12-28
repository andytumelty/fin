require 'test_helper'

class BudgetTest < ActiveSupport::TestCase
  test "should delete related reservations on delete" do
    b = Budget.create(
      start_date: Date.today - 1,
      end_date: Date.today,
      user: users(:user_1)
    )
    r = b.reservations
    assert b.destroy, "Could not destroy budget"
    r.reload
    assert_empty r, "Reservations not deleted"
  end

  test "should set name only if no name given" do
    name = "test budget"
    b = Budget.create(
      name: name,
      start_date: Date.today - 1,
      end_date: Date.today,
      user: users(:user_1)
    )
    assert_equal(
      name,
      b.name,
      "Name not set as expected"
    )
    b = Budget.create(
      start_date: Date.today - 1,
      end_date: Date.today,
      user: users(:user_1)
    )
    assert_equal(
      b.start_date.to_s + " to " + b.end_date.to_s,
      b.name,
      "Name not set as expected"
    )
  end

  test "should copy previous reservations on create" do
    b1 = Budget.create(
      start_date: Date.today - 1,
      end_date: Date.today,
      user: users(:user_1)
    )
    c_no_r = b1.user.categories.where.not(id: b1.reservations.map(&:category_id))
    c_no_r.sample(rand(1..c_no_r.count)).map{ |c|
      Reservation.create(
        budget: b1,
        category: c,
        amount: rand(-10..10),
        ignored: [true, false].sample
      )
    }
    b2 = Budget.create(
      start_date: Date.today - 1,
      end_date: Date.today,
      user: users(:user_1)
    )
    assert_equal(
      b1.reservations.order(:category_id).pluck(:category_id, :amount, :ignored),
      b2.reservations.order(:category_id).pluck(:category_id, :amount, :ignored),
      "budget reservations not equal"
    )
  end

  # TODO test "should calculate balance correctly"
end
