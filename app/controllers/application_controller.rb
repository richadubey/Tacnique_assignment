class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  include Clerk::Authenticatable

  private

  def require_clerk_user!
    return if clerk.user

    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
