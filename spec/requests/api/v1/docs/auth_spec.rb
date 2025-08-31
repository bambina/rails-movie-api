require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  path '/api/v1/auth/login' do
    post 'Login' do
      tags 'Auth'
      description 'Authenticate user and get JWT'
      consumes 'application/json'
      produces 'application/json'
      security []

      parameter name: :credentials, in: :body, required: true,
                schema: ApiSchemas::V1.auth_login_request

      response 200, 'successful login' do
        schema ApiSchemas::V1.auth_response
        let(:user) { create(:user, password: 'password') }
        let(:credentials) { { username: user.username, password: 'password' } }
        run_test! do
          expect(response.cookies['refresh_token']).to be_present
        end
      end

      response 401, 'invalid credentials' do
        schema ApiSchemas::V1.unauthorized_error
        let(:credentials) { { username: 'wrong', password: 'wrong' } }
        run_test! do
          expect(response.headers['Set-Cookie']).to be_nil.or satisfy { |h| !h.include?('refresh_token=') }
        end
      end
    end
  end

  path '/api/v1/auth/refresh' do
    post 'Refresh access token' do
      tags 'Auth'
      description 'Exchange a refresh token (HttpOnly cookie) for a new access token. Also rotates the refresh token.'
      consumes 'application/json'
      produces 'application/json'
      security [ cookieAuth: [] ]

      response 200, 'ok' do
        schema ApiSchemas::V1.auth_response
        let(:user) { create(:user, password: 'password') }

        before do
          # Call /login to set the refresh_token cookie
          post '/api/v1/auth/login',
              params: { username: user.username, password: 'password' }.to_json,
              headers: { 'CONTENT_TYPE' => 'application/json' }
          expect(response).to have_http_status(:ok)
        end

        run_test! do
          # Validate /refresh response
          json = JSON.parse(response.body)
          expect(json['token']).to be_present
          expect(json['token_type']).to eq('Bearer')
          expect(json['expires_in']).to be > 0
          expect(json['username']).to eq(user.username).or be_present

          # Check Set-Cookie for rotated refresh_token
          set_cookie = response.headers['Set-Cookie']
          expect(set_cookie).to include('refresh_token=')
          expect(set_cookie).to match(/;\s*httponly\b/i)
          expect(set_cookie).to match(/;\s*samesite=(strict|lax|none)\b/i)
          expect(set_cookie).to match(/expires=/i)
        end
      end

      response 401, 'invalid or expired refresh token' do
        schema ApiSchemas::V1.unauthorized_error
        before do
          cookies[:refresh_token] = 'invalid.token'
        end
        run_test!
      end
    end
  end
end
