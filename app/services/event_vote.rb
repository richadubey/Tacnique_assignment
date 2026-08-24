# frozen_string_literal: true

class EventVote
  def self.call(event:, user_id:, vote:)
    new(
      event: event,
      user_id: user_id,
      vote: vote
    ).call
  end

  def initialize(event:, user_id:, vote:)
    @event = event
    @user_id = user_id
    @vote = vote
  end

  def call
    event = build_event

    Rails.configuration.event_store.publish(
      event,
      stream_name: "Event$#{@event.id}"
    )

    event
  end

  private

  def build_event
    event_class.new(
      data: {
        event_id: @event.id,
        user_id: @user_id
      }
    )
  end

  def event_class
    case @vote
    when "up"
      EventUpvoted
    when "down"
      EventDownvoted
    else
      raise ArgumentError, "Invalid vote: #{@vote}"
    end
  end
end