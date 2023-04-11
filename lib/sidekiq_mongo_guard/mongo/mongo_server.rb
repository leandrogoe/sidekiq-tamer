require 'mongo'
require_relative 'mongo_command_subscriber'
require_relative 'mongo_configuration'

module SidekiqMongoGuard::Mongo
  class MongoServer
    def self.server_for(host, port)
      key = "#{host}:#{port}"
      servers[key] ||= MongoServer.new(host, port)
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
      if operation == :read
        wiredtiger_tickets["read"]["available"] > MongoConfiguration.ticket_threshold
      else
        wiredtiger_tickets["write"]["available"] > MongoConfiguration.ticket_threshold
      end
    end

    def wiredtiger_tickets
      if !@wiredtiger_tickets_read_at || @wiredtiger_tickets_read_at < Time.now - 60
        @wiredtiger_tickets = available_tickets
        @wiredtiger_tickets_read_at ||= Time.now
      end
      @wiredtiger_tickets
    end

    def available_tickets
      client.database.command('serverStatus'=> 1).documents[0]['wiredTiger']['concurrentTransactions']
    end

    def client
      @client ||= Mongo::Client.new(
        [ "#{host}:#{port}" ], database: 'admin', user: MongoConfiguration.user, password: MongoConfiguration.password, auth_source: 'admin',
      )
    end

    def clean_wired_tiger_tickets
      @wiredtiger_tickets_read_at = nil
    end
  end
end