RSpec.describe(SidekiqMongoGuard::Mongo::MongoConfiguration) do

  it 'registers the observer and config values' do
    SidekiqMongoGuard::Mongo::MongoConfiguration.setup(user: 'USER', password: 'PASS', ticket_threshold: 30)
    ::Mongo::Monitoring::Global.subscribers.any? { |sub| sub.is_a?(SidekiqMongoGuard::Mongo::MongoCommandSubscriber) }
    expect(SidekiqMongoGuard::Mongo::MongoConfiguration.user).to eq('USER')
    expect(SidekiqMongoGuard::Mongo::MongoConfiguration.password).to eq('PASS')
    expect(SidekiqMongoGuard::Mongo::MongoConfiguration.ticket_threshold).to eq(30)
  end

  it 'can use a proc instead of an actual value for config options' do
    SidekiqMongoGuard::Mongo::MongoConfiguration.setup(user: ->() { 'testUser' }, password: ->() { 'testPass' }, ticket_threshold: ->() { 99 })
    ::Mongo::Monitoring::Global.subscribers.any? { |sub| sub.is_a?(SidekiqMongoGuard::Mongo::MongoCommandSubscriber) }
    expect(SidekiqMongoGuard::Mongo::MongoConfiguration.user).to eq('testUser')
    expect(SidekiqMongoGuard::Mongo::MongoConfiguration.password).to eq('testPass')
    expect(SidekiqMongoGuard::Mongo::MongoConfiguration.ticket_threshold).to eq(99)
  end
end