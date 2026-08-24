# frozen_string_literal: true

module Billetto
  class EventMapper
    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
    end

    def call
      {
        billetto_id: @data.fetch("id"),
        title: @data["title"],
        description: @data["description"],
        url: @data["url"],
        image_url: @data["image_link"],
        starts_at: @data["startdate"],
        ends_at: @data["enddate"],
        available: @data["availability"],
        price_cents: @data.dig("minimum_price", "amount_in_cents"),
        currency: @data.dig("minimum_price", "currency"),
        category: @data.dig("categorization", "category"),
        subcategory: @data.dig("categorization", "subcategory"),
        event_type: @data.dig("categorization", "type"),
        organiser_id: @data.dig("organiser", "id"),
        organiser_name: @data.dig("organiser", "name"),
        location_name: @data.dig("location", "location_name"),
        address: @data.dig("location", "address_line"),
        city: @data.dig("location", "city"),
        postal_code: @data.dig("location", "postal_code"),
        country: @data.dig("location", "country"),
        country_code: @data.dig("location", "country_code"),
        latitude: @data.dig("location", "coordinates", "latitude"),
        longitude: @data.dig("location", "coordinates", "longitude")
      }
    end
  end
end