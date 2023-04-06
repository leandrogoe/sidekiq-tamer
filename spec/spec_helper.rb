require "bundler/setup"
require "pry-byebug"
require "sidekiq_mongo_guard"
require "sidekiq/testing"

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
    SidekiqMongoGuard::MongoClient.clean_wired_tiger_tickets
  end
end
