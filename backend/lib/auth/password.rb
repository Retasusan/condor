require "bcrypt"

module Auth
  module Password
    module_function

    def hash(plain)
      BCrypt::Password.create(plain).to_s
    end

    def verify(plain, digest)
      BCrypt::Password.new(digest) == plain

    rescue
      return false
    end
  end
end