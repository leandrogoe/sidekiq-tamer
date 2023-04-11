RSpec.describe(SidekiqResourceGuard::Mongo::MongoConfiguration) do

  it 'registers the observer and config values' do
    SidekiqResourceGuard::Mongo::MongoConfiguration.setup(user: 'USER', password: 'PASS', ticket_threshold: 30)
    ::Mongo::Monitoring::Global.subscribers.any? { |sub| sub.is_a?(SidekiqResourceGuard::Mongo::MongoCommandSubscriber) }
    expect(SidekiqResourceGuard::Mongo::MongoConfiguration.user).to eq('USER')
    expect(SidekiqResourceGuard::Mongo::MongoConfiguration.password).to eq('PASS')
    expect(SidekiqResourceGuard::Mongo::MongoConfiguration.ticket_threshold).to eq(30)
  end

  it 'can use a proc instead of an actual value for config options' do
    SidekiqResourceGuard::Mongo::MongoConfiguration.setup(user: ->() { 'testUser' }, password: ->() { 'testPass' }, ticket_threshold: ->() { 99 })
    ::Mongo::Monitoring::Global.subscribers.any? { |sub| sub.is_a?(SidekiqResourceGuard::Mongo::MongoCommandSubscriber) }
    expect(SidekiqResourceGuard::Mongo::MongoConfiguration.user).to eq('testUser')
    expect(SidekiqResourceGuard::Mongo::MongoConfiguration.password).to eq('testPass')
    expect(SidekiqResourceGuard::Mongo::MongoConfiguration.ticket_threshold).to eq(99)
  end
end