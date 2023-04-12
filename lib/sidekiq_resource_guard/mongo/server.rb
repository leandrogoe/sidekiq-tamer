require 'mongo'
require_relative 'command_subscriber'
require_relative 'configuration'

module SidekiqResourceGuard::Mongo
  class Server
    def self.server_for(host, port)
      key = "#{host}:#{port}"
      servers[key] ||= Server.new(host, port)
      servers[key]
    end

    def self.servers
      @servers ||= {}
    end

    def self.clear_servers
      @servers = {}
    end

    attr_reader :host, :port
    def initialize(host, port)
      @host = host
      @port = port
    end

    def is_operation_safe?(operation)
      average = wired_tiger_history.map { |entry|
        entry[:concurrentTransactions][operation.to_s]['available']
      }.sum / wired_tiger_history.count.to_f

      average >= Configuration.ticket_threshold
    end

    def wired_tiger_history
      @wired_tiger_history ||= []
      if !@wiredtiger_tickets_read_at || @wiredtiger_tickets_read_at < Time.now - 30
        @wired_tiger_history.push({ concurrentTransactions: available_tickets, read_at: Time.now })
        @wiredtiger_tickets_read_at = Time.now
      end
      @wired_tiger_history = @wired_tiger_history.select { |entry| entry[:read_at] >= Time.now - 60 * 2 }
    end

    def available_tickets
      client.database.command('serverStatus'=> 1).documents[0]['wiredTiger']['concurrentTransactions']
    end

    def client
      @client ||= Mongo::Client.new(
        [ "#{host}:#{port}" ], database: 'admin', user: Configuration.user, password: Configuration.password, auth_source: 'admin',
      )
    end

    def clean_wired_tiger_tickets
      @wiredtiger_tickets_read_at = nil
    end
  end
end