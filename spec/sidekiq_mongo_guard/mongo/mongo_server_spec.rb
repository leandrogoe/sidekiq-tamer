RSpec.describe(SidekiqMongoGuard::Mongo::MongoServer) do

  let(:host) { 'mongo' }
  let(:port) { 27017 }

  describe 'unauthorized' do
    before(:each) do
      SidekiqMongoGuard::Mongo::MongoConfiguration.setup(user: 'USER', password: 'PASS', ticket_threshold: 80)
    end

    it 'fails to query tickets if it does not have the appropriate role' do
      server = SidekiqMongoGuard::Mongo::MongoServer.new(host, port)
      expect(server.client.database).to receive(:command).with('serverStatus' => 1).exactly(1).times.and_call_original

      expect { server.is_operation_safe?(:write) }.to raise_error(Mongo::Error::OperationFailure)
    end
  end

  describe 'with proper access' do
    before(:each) do
      SidekiqMongoGuard::Mongo::MongoConfiguration.setup(user: 'clusterMonitor', password: 'PASS', ticket_threshold: 80)
    end

    it 'caches the wired tiger tickets' do
      server = SidekiqMongoGuard::Mongo::MongoServer.new(host, port)
      expect(server.client.database).to receive(:command).with('serverStatus' => 1).exactly(1).times.and_call_original

      expect(server.is_operation_safe?(:write)).to be_truthy
      expect(server.is_operation_safe?(:read)).to be_truthy
      expect(server.is_operation_safe?(:write)).to be_truthy
    end

    it 'returns unsafe for read when tickets are below the threshold' do
      server = SidekiqMongoGuard::Mongo::MongoServer.new(host, port)
      expect(server.client.database).to receive(:command).with('serverStatus' => 1).exactly(1).times.and_return(
        double(documents: [
          {
            'wiredTiger' => {
              'concurrentTransactions' => { 'read' => { "available" => 72 }, 'write' => { "available" => 99 } }
            }
          }
        ])
      )

      expect(server.is_operation_safe?(:read)).to be_falsey
      expect(server.is_operation_safe?(:write)).to be_truthy
    end

    it 'returns unsafe for write when tickets are below the threshold' do
      server = SidekiqMongoGuard::Mongo::MongoServer.new(host, port)
      expect(server.client.database).to receive(:command).with('serverStatus' => 1).exactly(1).times.and_return(
        double(documents: [
          {
            'wiredTiger' => {
              'concurrentTransactions' => { 'read' => { "available" => 99 }, 'write' => { "available" => 72 } }
            }
          }
        ])
      )

      expect(server.is_operation_safe?(:write)).to be_falsey
      expect(server.is_operation_safe?(:read)).to be_truthy
    end
  end

end