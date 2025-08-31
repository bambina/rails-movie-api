class Api::V1::AuthController < Api::BaseController
  # Authenticates a user with username and password
  def login
    user = User.find_by(username: params[:username].to_s.downcase.strip)

    if user&.authenticate(params[:password])
      exp   = 1.hour.from_now
      token = JsonWebToken.encode({ user_id: user.id }, exp: exp)

      render json: {
        token: token,
        token_type: "Bearer",
        expires_in: (exp.to_i - Time.now.to_i),
        username: user.username
      }
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end
end
