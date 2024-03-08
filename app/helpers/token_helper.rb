# frozen_string_literal: true

module TokenHelper
  module TokenGeneratorHelper
    def generate_auth_token(payload)
      JWT.encode({ jit: generate_uuid }.merge(payload), ENV['SECRET_KEY'], 'HS256')
    end

    private

    def generate_uuid
      SecureRandom.uuid_v4
    end
  end

  module TokenVerifierHelper

    def token_id_if_valid(token)
      begin
        token_payload = JWT.decode(token, ENV['SECRET_KEY'], true)[0]
        exp = token_payload["exp"]
        exp_datetime = DateTime.strptime("#{exp}", "%s")
        if is_expired(exp_datetime)
          return nil
        end
        token_payload["jit"]
      rescue
        nil
      end
    end

    private

    def is_expired(datetime)
      current_time = DateTime.now
      datetime < current_time
    end

  end
end
