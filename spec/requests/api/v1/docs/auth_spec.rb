require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  path '/api/v1/auth/login' do
    post 'Login' do
      tags 'Auth'
      description 'Authenticate user and get JWT'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, required: true,
                schema: ApiSchemas::V1.auth_login_request

      response 200, 'successful login' do
        schema ApiSchemas::V1.auth_login_response
        let(:user) { create(:user, password: 'password') }
        let(:credentials) { { username: user.username, password: 'password' } }
        run_test!
      end

      response 401, 'invalid credentials' do
        schema ApiSchemas::V1.unauthorized_error
        let(:credentials) { { username: 'wrong', password: 'wrong' } }
        run_test!
      end
    end
  end
end
