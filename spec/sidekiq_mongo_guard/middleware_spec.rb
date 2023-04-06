RSpec.describe(SidekiqMongoGuard::Middleware) do
  before(:each) do
    Sidekiq::Testing.server_middleware do |chain|
      chain.add SidekiqMongoGuard::Middleware
    end
  end

  describe 'when the job can be retried' do
    before(:each) do
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
      expect(SidekiqMongoGuard::Resource::Mongo).to receive(:available_tickets).and_return(
        { 'write' => { 'available' => 128 }, 'read' => { 'available' => 128 } }
      )

      expect { SimpleJob.perform_async }.to_not raise_error
      expect(SimpleJob.executions.count).to eq 1
    end

    it 'should prevent job execution when tickets are not enough' do
      expect(SidekiqMongoGuard::Resource::Mongo).to receive(:available_tickets).and_return(
        { 'write' => { 'available' => 1 }, 'read' => { 'available' => 1 } }
      )

      expect { SimpleJob.perform_async }.to raise_error(SidekiqMongoGuard::Middleware::ResourceUnhealthy)
      expect(SimpleJob.executions.count).to eq 0
    end
  end

  describe 'when the job does not accept retries' do
    before(:each) do
      simple_job = Class.new do
        include Sidekiq::Job
        sidekiq_options retry: false

        def self.executions
          @executions ||= []
        end

        def perform(*args)
          self.class.executions << args
        end
      end

      stub_const 'SimpleJob', simple_job
    end

    it 'should allow job execution even when tickets are not enough' do
      allow(SidekiqMongoGuard::Resource::Mongo).to receive(:available_tickets).and_return(
        { 'write' => { 'available' => 1 }, 'read' => { 'available' => 1 } }
      )

      expect { SimpleJob.perform_async }.to_not raise_error
      expect(SimpleJob.executions.count).to eq 1
    end
  end

  describe 'when the job accept retries, but they have run out' do
    before(:each) do
      simple_job = Class.new do
        include Sidekiq::Job
        sidekiq_options retry: 10

        def self.executions
          @executions ||= []
        end

        def perform(*args)
          self.class.executions << args
        end
      end

      stub_const 'SimpleJob', simple_job
    end

    it 'should allow job execution even when tickets are not enough' do
      allow(SidekiqMongoGuard::Resource::Mongo).to receive(:available_tickets).and_return(
        { 'write' => { 'available' => 1 }, 'read' => { 'available' => 1 } }
      )

      expect {
        Sidekiq::Client.push(
          'class' => 'SimpleJob',
          'args' => [],
          'retry_count' => 9,
          'retry' => 10
        )
       }.to_not raise_error
      expect(SimpleJob.executions.count).to eq 1
    end
  end
end