json.array!(@budgets) do |budget|
  json.extract! budget, :id, :name, :start_date, :end_date, :balance, :user_id
  json.url budget_url(budget, format: :json)
end
