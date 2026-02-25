require_relative "../db"

module Repos
  module UsersRepo
    module_function

    def create(username:, password_digest:)
      db[:users].insert(
        username: username,
        password_digest: password_digest
      )
    end

    def find_by_username(username)
      db[:users].where(username: username).first
    end

    def find_by_id(id)
      db[:users].where(id: id).first
    end
  end
end