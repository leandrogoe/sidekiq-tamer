require "sidekiq/mongo/guard/version"
require "sidekiq/mongo/guard/middleware"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Middleware
  end
end