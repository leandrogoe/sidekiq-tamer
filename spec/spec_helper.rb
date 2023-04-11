require "bundler/setup"
require "pry-byebug"
require "sidekiq_resource_guard"
require "sidekiq/testing"
require "timecop"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    Sidekiq::Testing.inline!
  end

  config.before(:each) do
    SidekiqResourceGuard::Mongo::MongoServer.clear_servers
    SidekiqResourceGuard::Mongo::MongoServerOperation.clear_server_operations
    SidekiqResourceGuard::Mongo::MongoConfiguration.clear
    SidekiqResourceGuard::Resource::Vault.clean_resources
    Thread.current[:sidekiq_resource_guard_job_name] = nil
  end
end
