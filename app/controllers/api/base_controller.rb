# Base controller for all API controllers.
# Provides common functionality for API endpoints:
# - Skips CSRF protection since APIs are stateless and typically use token-based authentication (e.g., JWT).
# - Implements user authentication via the `authenticate_user!` method.
class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  attr_reader :current_user

  private

  # Authenticates the current user based on a JWT token provided
  # in the `Authorization` header.
  def authenticate_user!
    header = request.headers["Authorization"].to_s
    unless (m = header.match(/\ABearer\s+(.+)\z/i))
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    token = m[1]
    payload = JsonWebToken.decode(token)

    @current_user = User.find_by(id: payload["user_id"])
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  rescue JWT::ExpiredSignature
    render json: { error: "Token expired" }, status: :unauthorized
  rescue JWT::DecodeError
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
