require 'mongoid'

class SidekiqMongoGuard::MongoClient
  def self.available_tickets
    Mongoid::Clients.default.database.command('serverStatus'=> 1).documents[0]['wiredTiger']['concurrentTransactions']
  end
end