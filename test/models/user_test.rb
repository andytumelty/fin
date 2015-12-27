require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should not save with short password" do
    p = "ab"
    u = User.new(
      username: "short_password",
      password: p,
      password_confirmation: p
    )
    assert_not u.save
  end

  test "should not save with wrong password confirmation" do
    p = 'abcdef'
    p_conf = 'fedcba'
    u = User.new(
      username: "different_pass_confirmation",
      password: p,
      password_confirmation: p_conf
    )
    assert_not u.save
  end

  test "should not save with non-unique username" do
    username = "same_username"
    p1 = 'alk23dqp!'
    p2 = 'AEEA)"1w1#'
    u = User.new(
      username: username,
      password: p1,
      password_confirmation: p1
    )
    assert u.save

    u = User.new(
      username: username,
      password: p2,
      password_confirmation: p2
    )
    assert_not u.save
  end

  test "should delete dependents on destroy" do
    username = "dependent-destroy"
    u = User.create(
      username: username,
      password: username,
      password_confirmation: username
    )
    3.times do |n|
      Account.create(
        name: "account_#{n}_#{u.id}",
        user: u
      )
      Category.create(
        name: "category_#{n}_#{u.id}",
        user: u
      )
      Budget.create(
        name: "budget#{n}_#{u.id}",
        user: u,
        start_date: Date.today - 10.days,
        end_date: Date.today
      )
    end
    a = u.accounts
    b = u.budgets
    c = u.categories
    assert u.destroy, "Could not destroy user"
    a.reload
    assert_empty a, "Accounts not destroyed"
    b.reload
    assert_empty b, "Budgets not destoyed"
    c.reload
    assert_empty c, "Categories not destroyed"
  end

  test "should create unassigned category on create" do
    username = "unassigned_create_test"
    u = User.new(
      username: username,
      password: username,
      password_confirmation: username
    )
    u.save
    assert_not_empty u.categories.where(name: "unassigned")
  end
end
