Sequel.migration do
  change do
    run "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

    create_table(:users) do
      primary_key :id, :uuid, default: Sequel.function(:gen_random_uuid)
      String :username, null: false, unique: true
      String :password_digest, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
