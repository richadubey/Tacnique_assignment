# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Billetto
  class Client
    BASE_URL = "https://billetto.dk/api/v3"

    def initialize
      @api_key = Rails.application.credentials.dig(:billetto, :api_key)
      @api_secret = Rails.application.credentials.dig(:billetto, :api_secret)

      raise "Billetto API key is missing" if @api_key.blank?
      raise "Billetto API secret is missing" if @api_secret.blank?
    end

    def public_events(limit: 100, after: nil)
      uri = URI("#{BASE_URL}/public/events")

      params = { limit: limit }
      params[:after] = after if after.present?

      uri.query = URI.encode_www_form(params)

      request(uri)
    end

    def public_events_next(url)
      uri = URI(url)

      request(uri)
    end

    private

    def request(uri)
      http_request = Net::HTTP::Get.new(uri)
      http_request["Accept"] = "application/json"
      http_request["Api-Keypair"] = "#{@api_key}:#{@api_secret}"

      response = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https"
      ) do |http|
        http.request(http_request)
      end

      handle_response(response)
    end

    def handle_response(response)
      body = JSON.parse(response.body)

      return body if response.is_a?(Net::HTTPSuccess)

      raise "Billetto API error: #{response.code} - #{body}"
    end
  end
end