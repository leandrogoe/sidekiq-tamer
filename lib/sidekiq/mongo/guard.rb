require "sidekiq/mongo/guard/version"
require "sidekiq/mongo/guard/middleware"
require "sidekiq"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Mongo::Guard::Middleware
  end
end