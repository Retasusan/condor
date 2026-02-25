require "dotenv/load"
require "sequel"

DATABASE_URL = ENV.fetch("DATABASE_URL")

def db
  @db ||= Sequel.connect(DATABASE_URL)
end