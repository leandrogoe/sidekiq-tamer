require "sidekiq_mongo_guard/version"
require "sidekiq_mongo_guard/middleware"
require "sidekiq"

module SidekiqMongoGuard
  def self.setup
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add SidekiqMongoGuard::Middleware
      end
    end
  end
end

SidekiqMongoGuard.setup