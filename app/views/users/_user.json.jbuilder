json.extract! user, :id, :name, :file1_key, :file2_key, :file3_key, :created_at, :updated_at
json.url user_url(user, format: :json)
