# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # Provides implementation of an OmniAuth strategy that works with samedi Booking API.
    #
    # For more information, consult the OmniAuth Strategy Contribution Guide:
    # https://github.com/omniauth/omniauth/wiki/Strategy-Contribution-Guide
    #
    # Note: this file is explicitly required by config/initializers/omniauth.rb so changes to it
    # won't be automatically reloaded and you need to restart the Rails app after every change to the strategy.
    # Changing `require` to `require_dependency` won't work, because Rails doesn't clear dependencies
    # required by initializers.
    class Samedi < OmniAuth::Strategies::OAuth2
      BOOKING_AUTH_URL = 'https://patient.samedi.de/api/auth/v2'.freeze
      BOOKING_API_URL = 'https://patient.samedi.de/api/booking/v3'.freeze

      option :name, 'samedi'
      option(
        :client_options,
        site: BOOKING_AUTH_URL,
        authorize_url: "#{BOOKING_AUTH_URL}/authorize",
        token_url: "#{BOOKING_AUTH_URL}/token"
      )

      uid do
        user_info.dig('user', 'id')
      end

      info do
        user_data = user_info['user']

        if user_data
          {
            name: user_data['full_name'],
            email: user_data['email'],
            first_name: user_data['first_name'],
            last_name: user_data['last_name']
          }
        else
          {}
        end
      end

      extra do
        { raw_info: user_info['user'] }
      end

      private

      # samedi Booking API doesn't like a query string inside redirect_uri, so we need to override it explicitly
      def query_string
        ''
      end

      def user_info
        return @user_info if @user_info

        user_info_response = fetch_user_info
        return {} unless user_info_response

        @user_info = MultiJson.load(user_info_response.body)
      end

      def fetch_user_info
        response = booking_api_client.get('user')

        return response if response.success?

        fail!("error_#{response.status}_getting_user_info")
        nil
      rescue Faraday::TimeoutError => e
        fail!(:timeout_getting_user_info, e)
        nil
      end

      def booking_api_client
        @booking_api_client ||= Faraday.new(BOOKING_API_URL) do |faraday|
          faraday.headers = { 'Authorization': "Bearer #{access_token.token}" }
          faraday.adapter Faraday.default_adapter
        end
      end
    end
  end
end
