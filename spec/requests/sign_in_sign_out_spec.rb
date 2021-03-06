require "rails_helper"

describe "Sign in", type: :request do
  let(:headers)   {}
  let(:params)    {}
  let(:email)     {"foo@bar.com"}
  let(:api_token) {"abc123"}
  let(:password)  {}
  let(:uid)  {}

  let!(:user) { User.create(uid: uid, provider: provider, email: email, password: password, api_token: api_token) }

  context 'signin' do
    before do
      post "/auth/sign_in", params, headers
    end

    context 'with email/password' do
      let(:provider) { "email" }
      let(:password)  {"needstobeaminimumof8characters"}
      let(:params)    {{email: email, password: password}}

      it 'returns the signed in user' do
        expect(response.status).to eq 200
        expect(response.headers["access-token"]).to be
        expect(response.headers["token-type"]).to eq "Bearer"
        expect(response.body).to eq "{\"data\":\"{\\\"id\\\":1,\\\"email\\\":\\\"foo@bar.com\\\"}\"}"
      end
    end
  end

  context 'accessing protected routes' do
    before do
      get "/testme", params, headers
    end

    context 'with email/password' do
      let(:provider) { "email" }
      let(:password)  {"needstobeaminimumof8characters"}
      let(:params)    {{email: email, password: password}}

      it 'returns the signed in user' do
        expect(response.status).to eq 401
      end
    end

    context 'api' do
      let(:provider)  {"api"}
      let(:uid)       {Base64.urlsafe_encode64(api_token)}
      let(:api_token) {"abc123"}
      let(:headers)   {{"Authorization" => api_token}}

      it "returns success" do
        expect(response.status).to eq 200
        expect(response.body).to eq "Hello #{user.email}"
      end
    end
  end

end
