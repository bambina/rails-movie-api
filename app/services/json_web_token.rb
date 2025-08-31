# Utility class for encoding and decoding JSON Web Tokens (JWT).
class JsonWebToken
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
end
