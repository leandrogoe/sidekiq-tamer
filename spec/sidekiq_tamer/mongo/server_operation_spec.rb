RSpec.describe(SidekiqTamer::Mongo::ServerOperation) do

  before(:each) do
    SidekiqTamer::Mongo::Configuration.setup(user: 'USER', password: 'PASSWORD')
  end

  describe 'reads' do
    before(:each) do
      staff_finder = Class.new do
        include Sidekiq::Worker

        def perform
          client = Mongo::Client.new(
            [ 'mongo:27017' ],
            database: 'mydb',
            user: 'USER',
            password: 'PASS',
            auth_source: 'admin',
          )
          staff = client.database[:staff]
          first_staff = staff.find.first
        end
      end

      stub_const('StaffFinder', staff_finder)
    end

    it 'registers operations correctly' do
      staff_finder_resources = SidekiqTamer::Resource::Vault.get_resources_for(StaffFinder)
      expect(staff_finder_resources.count).to eq 0
      StaffFinder.perform_async
      staff_finder_resources = SidekiqTamer::Resource::Vault.get_resources_for(StaffFinder)
      expect(staff_finder_resources.count).to eq 1
      expect(staff_finder_resources.first.class).to eq(SidekiqTamer::Mongo::ServerOperation)
      expect(staff_finder_resources.first.operation).to eq(:read)
    end

    context 'when middleware is active' do

      before(:each) do
        Sidekiq::Testing.server_middleware do |chain|
          chain.add SidekiqTamer::Middleware
        end

        StaffFinder.perform_async
      end

      it 'rejects jobs when read tickets are low' do
        expect(SidekiqTamer::Mongo::Server.servers.values.first).to receive(:is_operation_safe?).with(:read).and_return(false)

        expect { StaffFinder.perform_async }.to raise_error(SidekiqTamer::Middleware::ResourceUnhealthy)
      end
    end
  end

  describe 'writes' do
    before(:each) do
      staff_finder = Class.new do
        include Sidekiq::Worker

        def perform
          client = Mongo::Client.new(
            [ 'mongo:27017' ],
            database: 'mydb',
            user: 'USER',
            password: 'PASS',
            auth_source: 'admin'
          )
          staff = client.database[:staff]
          first_staff = staff.insert_one({ name: 'Bryan'})
        end
      end

      stub_const('StaffFinder', staff_finder)
    end

    it 'registers operations correctly' do
      staff_finder_resources = SidekiqTamer::Resource::Vault.get_resources_for(StaffFinder)
      expect(staff_finder_resources.count).to eq 0
      StaffFinder.perform_async
      staff_finder_resources = SidekiqTamer::Resource::Vault.get_resources_for(StaffFinder)
      expect(staff_finder_resources.count).to eq 1
      expect(staff_finder_resources.first.class).to eq(SidekiqTamer::Mongo::ServerOperation)
      expect(staff_finder_resources.first.operation).to eq(:write)
    end

    context 'when middleware is active' do

      before(:each) do
        Sidekiq::Testing.server_middleware do |chain|
          chain.add SidekiqTamer::Middleware
        end

        StaffFinder.perform_async
      end

      it 'rejects jobs when read tickets are low' do
        expect(SidekiqTamer::Mongo::Server.servers.values.first).to receive(:is_operation_safe?).with(:write).and_return(false)

        expect { StaffFinder.perform_async }.to raise_error(SidekiqTamer::Middleware::ResourceUnhealthy)
      end
    end
  end
end