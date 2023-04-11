RSpec.describe(SidekiqMongoGuard::Middleware) do
  let(:dummy_resource) {
    dummy_resource = Class.new do
      def name
        "dummy resource"
      end

      def is_consumed_by?(job)
        true
      end

      def is_healthy?
        true
      end
    end

    stub_const("DummyResource", dummy_resource)

    DummyResource.new
  }

  before(:each) do
    Sidekiq::Testing.server_middleware do |chain|
      chain.add SidekiqMongoGuard::Middleware
    end

    SidekiqMongoGuard::Resource::Vault.add_resources(dummy_resource)
  end

  describe 'when the job can be retried' do
    before(:each) do
      simple_job = Class.new do
        include Sidekiq::Worker

        def self.executions
          @executions ||= []
        end

        def perform(*args)
          self.class.executions << args
        end
      end

      stub_const 'SimpleJob', simple_job
    end

    it 'should allow job execution when the resource is healthy' do
      expect(dummy_resource).to receive(:is_healthy?).and_return(true)

      expect { SimpleJob.perform_async }.to_not raise_error
      expect(SimpleJob.executions.count).to eq 1
    end

    it 'should prevent job execution when the resource is not healthy' do
      expect(dummy_resource).to receive(:is_healthy?).and_return(false)

      expect { SimpleJob.perform_async }.to raise_error(SidekiqMongoGuard::Middleware::ResourceUnhealthy)
      expect(SimpleJob.executions.count).to eq 0
    end

    it 'should allow job execution when the resource is not healthy but the job does not depend on it' do
      allow(dummy_resource).to receive(:is_healthy?).and_return(false)
      expect(dummy_resource).to receive(:is_consumed_by?).and_return(false)

      expect { SimpleJob.perform_async }.to_not raise_error
      expect(SimpleJob.executions.count).to eq 1
    end
  end

  describe 'when the job does not accept retries' do
    before(:each) do
      simple_job = Class.new do
        include Sidekiq::Worker
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

    it 'should allow job execution even when the resource is not healthy' do
      allow(dummy_resource).to receive(:is_healthy?).and_return(true)

      expect { SimpleJob.perform_async }.to_not raise_error
      expect(SimpleJob.executions.count).to eq 1
    end
  end

  describe 'when the job accept retries, but they have run out' do
    before(:each) do
      simple_job = Class.new do
        include Sidekiq::Worker
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

    it 'should allow job execution even when the resource is not healthy' do
      allow(dummy_resource).to receive(:is_healthy?).and_return(true)

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