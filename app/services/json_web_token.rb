# Utility class for encoding and decoding JSON Web Tokens (JWT).
# https://datatracker.ietf.org/doc/html/rfc7519
class JsonWebToken
  # TODO: Use ES256
  ALGO = "HS256"

  # Encodes a payload into a JWT string with an expiration time.
  def self.encode(payload, exp: 1.hour.from_now)
    data = payload.dup
    data[:exp] = exp.to_i
    JWT.encode(data, secret_key, ALGO)
  end

  # Decodes a JWT string and returns the payload.
  def self.decode(token)
    JWT.decode(token, secret_key, true, { algorithm: ALGO, leeway: 5 }).first
  end

  # Returns the secret key used for signing and verifying JWTs.
  def self.secret_key
    ENV["JWT_SECRET"].presence || Rails.application.secret_key_base
  end

  # Issues a short-lived access token for authenticating API requests.
  def self.issue_access_token(user, exp: 1.hour.from_now)
    encode({ user_id: user.id, type: "access" }, exp: exp)
  end

  # Issues a long-lived refresh token for obtaining new access tokens.
  def self.issue_refresh_token(user, exp: 14.days.from_now)
    encode({ user_id: user.id, type: "refresh", jti: SecureRandom.uuid }, exp: exp)
  end
end
