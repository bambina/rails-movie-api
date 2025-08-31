# frozen_string_literal: true

RSpec.shared_context 'with authenticated user' do
  let(:user) { create(:user, password: 'password') }
  let(:Authorization) { "Bearer #{JsonWebToken.encode({ user_id: user.id })}" }
end
