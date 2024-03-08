class AuthenticationController < ApplicationController
  include TokenHelper::TokenGeneratorHelper
  include TokenHelper::TokenVerifierHelper

  def signup
    full_name = params[:full_name]
    phone_number = params[:phone_number]
    address = params[:address]
    password = params[:password]

    user = User.find_by(phone_number: phone_number)
    if user
      render json: { "message": "User with phone number already exist" }, status: :bad_request
    else
      new_user = User.new(full_name: full_name, phone_number: phone_number, address: address)
      new_user.password = password
      if new_user.save
        render json: new_user.as_json(except: [:password_digest]), status: :created
      else
        render json: new_user.errors, status: :unprocessable_entity
      end
    end
  end

  def login
    phone_number = params[:phone_number]
    password = params[:password]

    user = User.find_by(phone_number: phone_number)

    if user != nil
      if user.password == password
        if user.is_verified

          access_token = generate_auth_token({ iss: user.id,
                                               exp: DateTime.now.advance(days: 5).to_i })

          refresh_token = generate_auth_token({ iss: user.id,
                                                exp: DateTime.now.advance(weeks: 1).to_i })

          render json: { "user": user.as_json(except: [:password_digest]), "access_token": access_token, "refresh_token": refresh_token }, status: :ok
        else
          render json: { "message": "User not verified" }, status: :bad_request
        end
      else
        render json: { "message": "Invalid credential" }, status: :bad_request
      end
    else
      render json: { "message": "User with this phone number doesn't exist" }, status: :not_found
    end
  end

  def verify_phone_number
    phone_number = params[:phone_number]
    code = params[:code]

    user = User.find_by(phone_number: phone_number)

    if user != nil
      if !user.is_verified
        # TODO check for sent code and compare
        if code == "12345"
          user.is_verified = true
          if user.save
            render json: user.as_json(except: [:password_digest])
          end
        else
          render json: { "message": "Invalid code" }, status: :bad_request
        end
      else
        render json: user.as_json(except: [:password_digest])
      end
    else
      render json: { "message": "User with this phone number doesn't exist" }, status: :not_found
    end
  end

  def logout
    authorization = request.authorization
    if authorization == nil || authorization.empty?
      render json: { "message": "Token missing" }, status: :forbidden
    else
      auth_token = authorization.split(" ")[1]
      token_id = token_id_if_valid(auth_token)
      if token_id == nil
        render json: { "message": "Invalid token" }, status: :forbidden
      end
      already_blacklisted = TokenBlacklist.find_by(token_id: token_id) != nil
      if already_blacklisted
        render json: { "message": "Token expired" }, status: :forbidden
      else
        TokenBlacklist.new(token_id: token_id).save
        render json: { "message": "Logout successfully!" }, status: :ok
      end
    end

  end

end