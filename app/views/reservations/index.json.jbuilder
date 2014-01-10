json.array!(@reservations) do |reservation|
  json.extract! reservation, :id, :category_id, :amount, :balance, :ignored, :budget_id
  json.url reservation_url(reservation, format: :json)
end
