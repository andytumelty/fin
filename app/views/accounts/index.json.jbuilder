json.array!(@accounts) do |account|
  json.extract! account, :id, :name, :references
  json.url account_url(account, format: :json)
end
