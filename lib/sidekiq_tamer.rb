require "sidekiq_tamer/version"
require "sidekiq_tamer/middleware"
require "sidekiq_tamer/mongo/server_operation"
require "sidekiq"

module SidekiqTamer
  def self.setup
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add SidekiqTamer::Middleware
      end
    end
  end
end

SidekiqTamer.setup