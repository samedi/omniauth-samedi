# frozen_string_literal: true

require 'rack/test'
require 'omniauth/strategies/samedi'
require 'addressable'

RSpec.describe OmniAuth::Strategies::Samedi do
  include Rack::Test::Methods

  let(:client_id) { 'foobar' }
  let(:client_secret) { 'barbaz123' }

  # Set up a Rack app against which test requests will be performed
  let(:app) do
    strat = strategy
    Rack::Builder.new do
      use(OmniAuth::Test::PhonySession)
      use(*strat)
      run ->(env) { [200, { 'Content-Type' => 'text/plain' }, [env.fetch('omniauth.auth').to_json]] }
    end.to_app
  end

  # Defines the OmniAuth strategy under test
  subject(:strategy) do
    [
      OmniAuth::Strategies::Samedi,
      client_id,
      client_secret,
      request_path: '/samedi/oauth',
      callback_path: '/samedi/oauth/callback'
    ]
  end

  describe '#request_phase' do
    it 'redirects to the Samedi authorization page' do
      get '/samedi/oauth'

      expect(last_response.status).to eq(302)
      location = Addressable::URI.parse(last_response.headers['Location'])

      expect(location.scheme).to eq 'https'
      expect(location.host).to eq 'patient.samedi.de'
      expect(location.path).to eq '/api/auth/v2/authorize'
      expect(location.query_values['response_type']).to eq 'code'
      expect(location.query_values['client_id']).to eq client_id
      expect(location.query_values['redirect_uri']).to eq 'http://example.org/samedi/oauth/callback'
    end
  end

  describe '#callback_phase' do
    it 'exchanges the Authorization Code for Access Token' do
      code = 'foobar123'
      access_token = 'xyz789'
      state = SecureRandom.alphanumeric(48)

      stub_request(:post, 'https://patient.samedi.de/api/auth/v2/token')
        .with(
          body: {
            grant_type: 'authorization_code',
            client_id: client_id,
            client_secret: client_secret,
            code: code,
            redirect_uri: 'http://example.org/samedi/oauth/callback'
          }
        )
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: { access_token: access_token }.to_json
        )

      stub_request(:get, 'https://patient.samedi.de/api/booking/v3/user')
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: {
            user: {
              id: 'dac9fffa-d1bb-39a8-9ce6-2e11e0cb66d7',
              full_name: 'Rogers, Anne',
              last_name: 'Rogers',
              first_name: 'Anne',
              email: 'anne@rogers.de',
              insurance_number: nil,
              insurance_company_id: 5
            }
          }.to_json
        )

      get(
        '/samedi/oauth/callback',
        { code: code, state: state },
        'rack.session' => { 'omniauth.state' => state }
      )

      expect(last_response.status).to eq 200
      body = JSON.parse(last_response.body)

      expect(body['credentials']).to eq(
        'token' => access_token,
        'expires' => false
      )

      expect(body['uid']).to eq('dac9fffa-d1bb-39a8-9ce6-2e11e0cb66d7')

      expect(body['info']).to eq(
        'name' => 'Rogers, Anne',
        'email' => 'anne@rogers.de',
        'first_name' => 'Anne',
        'last_name' => 'Rogers'
      )

      expect(body['extra']).to eq(
        'raw_info' => {
          'id' => 'dac9fffa-d1bb-39a8-9ce6-2e11e0cb66d7',
          'full_name' => 'Rogers, Anne',
          'last_name' => 'Rogers',
          'first_name' => 'Anne',
          'email' => 'anne@rogers.de',
          'insurance_number' => nil,
          'insurance_company_id' => 5
        }
      )
    end

    it 'redirects to an auth error URL if auth fails' do
      code = 'foobar123'
      state = SecureRandom.alphanumeric(48)

      stub_request(:post, 'https://patient.samedi.de/api/auth/v2/token')
        .with(
          body: {
            grant_type: 'authorization_code',
            client_id: client_id,
            client_secret: client_secret,
            code: code,
            redirect_uri: 'http://example.org/samedi/oauth/callback'
          }
        )
        .to_return(status: [500, 'Internal Server Error'])

      get(
        '/samedi/oauth/callback',
        { code: code, state: state },
        'rack.session' => { 'omniauth.state' => state }
      )

      expect(last_response.status).to eq(302)
      location = Addressable::URI.parse(last_response.headers['Location'])

      expect(location.path).to eq '/auth/failure'
      expect(location.query_values['message']).to eq 'invalid_credentials'
      expect(location.query_values['strategy']).to eq 'samedi'
    end

    it 'succeeds even if fetching user details fails' do
      code = 'foobar123'
      access_token = 'xyz789'
      state = SecureRandom.alphanumeric(48)

      stub_request(:post, 'https://patient.samedi.de/api/auth/v2/token')
        .with(
          body: {
            grant_type: 'authorization_code',
            client_id: client_id,
            client_secret: client_secret,
            code: code,
            redirect_uri: 'http://example.org/samedi/oauth/callback'
          }
        )
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: { access_token: access_token }.to_json
        )

      stub_request(:get, 'https://patient.samedi.de/api/booking/v3/user')
        .to_return(status: [500, 'Internal Server Error'])

      get(
        '/samedi/oauth/callback',
        { code: code, state: state },
        'rack.session' => { 'omniauth.state' => state }
      )

      expect(last_response.status).to eq 200
      body = JSON.parse(last_response.body)

      expect(body['credentials']).to eq(
        'token' => access_token,
        'expires' => false
      )

      expect(body['uid']).to eq(nil)
      expect(body['info']).to eq('name' => nil)
      expect(body['extra']).to eq('raw_info' => nil)
    end
  end
end
