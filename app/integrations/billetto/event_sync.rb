# frozen_string_literal: true

module Billetto
  class EventSync
    def self.call(limit: 100)
      new(limit: limit).call
    end

    def initialize(limit:)
      @limit = limit
      @client = Billetto::Client.new
    end

    def call
      synced_events = []

      response = @client.public_events(limit: @limit)

      loop do
        response.fetch("data").each do |event_data|
          event = sync_event(event_data)
          synced_events << event if event
        end

        break unless response["has_more"]

        response = @client.public_events_next(response.fetch("next_url"))
      end

      synced_events
    end

    private

    def sync_event(event_data)
      attributes = EventMapper.call(event_data)

      event = Event.find_or_initialize_by(
        billetto_id: attributes[:billetto_id]
      )

      event.assign_attributes(attributes)

      if event.save
        event
      else
        Rails.logger.warn(
          "Skipping Billetto event #{event.billetto_id}: " \
          "#{event.errors.full_messages.join(', ')}"
        )

        nil
      end
    end
  end
end