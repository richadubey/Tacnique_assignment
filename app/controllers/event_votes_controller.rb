class EventVotesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :require_clerk_user!
  def create
    event = Event.find(params[:id])

    vote_event = EventVote.call(
      event: event,
      user_id: clerk.user.id,
      vote: params[:vote]
    )

    render json: {
      event_id: event.id,
      vote: params[:vote],
      event_type: vote_event.event_type
    }, status: :created
  end
end