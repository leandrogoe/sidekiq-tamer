RSpec.describe Sidekiq::Mongo::Guard do
  before do
    require "sidekiq"
    allow(Sidekiq).to receive(:server?).and_return(true)
    require "sidekiq/mongo/guard"
  end

  it "has a version number" do
    expect(Sidekiq::Mongo::Guard::VERSION).not_to be nil
  end

  it "adds the middleware when on server mode" do
    expect(Sidekiq.server_middleware.chain.first.klass).to eq(Sidekiq::Mongo::Guard::Middleware)
  end
end
