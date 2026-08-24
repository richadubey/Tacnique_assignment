require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "valid event" do
    event = Event.new(
      billetto_id: "12345",
      title: "Test Event",
      starts_at: Time.current,
      ends_at: 1.hour.from_now
    )

    assert event.valid?
  end

  test "billetto_id must be unique" do
    Event.create!(
      billetto_id: "12345",
      title: "First Event",
      starts_at: Time.current,
      ends_at: 1.hour.from_now
    )

    duplicate = Event.new(
      billetto_id: "12345",
      title: "Second Event",
      starts_at: Time.current,
      ends_at: 1.hour.from_now
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:billetto_id], "has already been taken"
  end

  test "starts_at and ends_at are required" do
    event = Event.new(
      billetto_id: "12345",
      title: "Test Event"
    )

    assert_not event.valid?
    assert_includes event.errors[:starts_at], "can't be blank"
    assert_includes event.errors[:ends_at], "can't be blank"
  end
end