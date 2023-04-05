RSpec.describe(SidekiqMongoGuard::Middleware) do
  before(:each) do
    Sidekiq::Testing.server_middleware do |chain|
      chain.add SidekiqMongoGuard::Middleware
    end

    simple_job = Class.new do
      include Sidekiq::Job

      def self.executions
        @executions ||= []
      end

      def perform(*args)
        self.class.executions << args
      end
    end

    stub_const 'SimpleJob', simple_job
  end

  it 'should allow job execution when tickets are enough' do
    expect(SidekiqMongoGuard::MongoClient).to receive(:available_tickets).and_return(
      { 'write' => { 'available' => 128 }, 'read' => { 'available' => 128 } }
    )

    expect { SimpleJob.perform_async }.to_not raise_error(SidekiqMongoGuard::Middleware::TicketsTooLowError)

    expect(SimpleJob.executions.count).to eq 1
  end

  it 'should prevent job execution when tickets are not enough' do
    expect(SidekiqMongoGuard::MongoClient).to receive(:available_tickets).and_return(
      { 'write' => { 'available' => 1 }, 'read' => { 'available' => 1 } }
    )

    expect { SimpleJob.perform_async }.to raise_error(SidekiqMongoGuard::Middleware::TicketsTooLowError)

    expect(SimpleJob.executions.count).to eq 0
  end
end