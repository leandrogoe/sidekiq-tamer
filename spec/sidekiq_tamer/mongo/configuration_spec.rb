RSpec.describe(SidekiqTamer::Mongo::Configuration) do

  it 'registers the observer and config values' do
    SidekiqTamer::Mongo::Configuration.setup(user: 'USER', password: 'PASS', ticket_threshold: 30)
    ::Mongo::Monitoring::Global.subscribers.any? { |sub| sub.is_a?(SidekiqTamer::Mongo::CommandSubscriber) }
    expect(SidekiqTamer::Mongo::Configuration.user).to eq('USER')
    expect(SidekiqTamer::Mongo::Configuration.password).to eq('PASS')
    expect(SidekiqTamer::Mongo::Configuration.ticket_threshold).to eq(30)
  end

  it 'can use a proc instead of an actual value for config options' do
    SidekiqTamer::Mongo::Configuration.setup(user: ->() { 'testUser' }, password: ->() { 'testPass' }, ticket_threshold: ->() { 99 })
    ::Mongo::Monitoring::Global.subscribers.any? { |sub| sub.is_a?(SidekiqTamer::Mongo::CommandSubscriber) }
    expect(SidekiqTamer::Mongo::Configuration.user).to eq('testUser')
    expect(SidekiqTamer::Mongo::Configuration.password).to eq('testPass')
    expect(SidekiqTamer::Mongo::Configuration.ticket_threshold).to eq(99)
  end
end