# # frozen_string_literal: true
#
# class TokenInterceptor
#   def initialize(app)
#     @app = app
#   end
#
#   def call(env)
#     authorization = ActionDispatch::Request.new(env).authorization
#     if authorization.empty?
#
#     else
#       auth_token = authorization.split(" ")[1]
#       if is_valid(auth_token)
#         @app.call(env)
#       end
#     end
#   end
#
#   private
#
#   def is_valid(token)
#     exp = JWT.decode(token, ENV['SECRET_KEY'], true)[0]["exp"]
#     exp_datetime = DateTime.strptime("#{exp}", "%s")
#     !is_expired(exp_datetime)
#   end
#
#   def is_expired(datetime)
#     current_time = DateTime.now
#     datetime < current_time
#   end
# end