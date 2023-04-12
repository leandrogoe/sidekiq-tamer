require "sidekiq_resource_guard/version"
require "sidekiq_resource_guard/middleware"
require "sidekiq_resource_guard/mongo/server_operation"
require "sidekiq"

module SidekiqResourceGuard
  def self.setup
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add SidekiqResourceGuard::Middleware
      end
    end
  end
end

SidekiqResourceGuard.setup