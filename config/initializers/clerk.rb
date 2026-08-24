# frozen_string_literal: true

Clerk.configure do |config|
  config.secret_key = Rails.application.credentials.dig(:clerk, :secret_key)
end