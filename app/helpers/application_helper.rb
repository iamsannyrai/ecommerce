module ApplicationHelper
  def generate_auth_token(payload)
    JWT.encode({ jit: generate_uuid }.merge(payload), ENV['SECRET_KEY'], 'HS256')
  end

  def generate_uuid
    SecureRandom.uuid_v4
  end
end
