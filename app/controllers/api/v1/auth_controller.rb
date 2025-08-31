class Api::V1::AuthController < Api::BaseController
  # Authenticates a user with username and password,
  # issues an access token (in JSON) and a refresh token (as HttpOnly cookie).
  def login
    # Find the user by username (case-insensitive, trimmed)
    user = User.find_by(username: params[:username].to_s.downcase.strip)

    if user&.authenticate(params[:password])
      # Token expiration times
      access_exp  = 1.hour.from_now
      refresh_exp = 14.days.from_now

      # Generate tokens
      access_token  = JsonWebToken.issue_access_token(user, exp: access_exp)
      refresh_token = JsonWebToken.issue_refresh_token(user, exp: refresh_exp)

      # Store refresh token securely in an encrypted HttpOnly cookie
      cookies.encrypted[:refresh_token] = {
        value:     refresh_token,
        httponly:  true,
        secure:    Rails.env.production?, # only over HTTPS in production
        same_site: :strict,
        expires:   refresh_exp
      }

      # Return access token in response body
      render json: {
        token: access_token,
        token_type: "Bearer",
        expires_in: (access_exp.to_i - Time.now.to_i),
        username: user.username
      }
    else
      # Authentication failed
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  # Exchanges a valid refresh token (from cookie) for a new access token,
  # and rotates the refresh token.
  def refresh
    # Read refresh token from secure cookie
    raw = cookies.encrypted[:refresh_token]

    # Decode and validate token type
    payload = JsonWebToken.decode(raw)
    raise JWT::DecodeError, "invalid token type" unless payload["type"] == "refresh"

    # Find the user associated with the token
    user = User.find(payload["user_id"])

    # Issue a new short-lived access token
    new_access_exp   = 1.hour.from_now
    new_access_token = JsonWebToken.issue_access_token(user, exp: new_access_exp)

    # Issue and rotate the refresh token
    new_refresh_exp   = 14.days.from_now
    new_refresh_token = JsonWebToken.issue_refresh_token(user, exp: new_refresh_exp)

    cookies.encrypted[:refresh_token] = {
      value:     new_refresh_token,
      httponly:  true,
      secure:    Rails.env.production?, # only over HTTPS in production
      same_site: :strict,
      expires:   new_refresh_exp
    }

    # Return new access token in response
    render json: {
      token: new_access_token,
      token_type: "Bearer",
      expires_in: (new_access_exp.to_i - Time.now.to_i),
      username: user.username
    }

  # Handle expired or invalid refresh tokens
  rescue JWT::ExpiredSignature
    render json: { error: "Refresh token expired" }, status: :unauthorized
  rescue JWT::DecodeError => e
    render json: { error: "Invalid refresh token" }, status: :unauthorized
  end
end
