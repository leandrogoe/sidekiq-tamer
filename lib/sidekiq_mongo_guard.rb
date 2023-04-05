require "sidekiq_mongo_guard/version"
require "sidekiq_mongo_guard/middleware"
require "sidekiq_mongo_guard/mongo_client"
require "sidekiq"

module SidekiqMongoGuard
  def self.configure
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add SidekiqMongoGuard::Middleware
      end
    end
  end
end

SidekiqMongoGuard.configure