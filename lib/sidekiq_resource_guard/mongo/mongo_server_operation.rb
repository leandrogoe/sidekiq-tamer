require 'mongo'
require_relative 'mongo_command_subscriber'
require_relative '../resource/resource_dependencies'
require_relative 'mongo_server'

module SidekiqResourceGuard::Mongo
  class MongoServerOperation
    include SidekiqResourceGuard::Resource::ResourceDependencies

    def self.server_operation_for(host, port, operation)
      key = "#{host}:#{port}:#{operation}"
      server_operations[key] ||= MongoServerOperation.new(host, port, operation)
      server_operations[key]
    end

    def self.clear_server_operations
      @server_operations = {}
    end

    def self.server_operations
      @server_operations ||= {}
    end

    attr_reader :operation, :server
    def initialize(host, port, operation)
      @server = MongoServer.server_for(host, port)
      @operation = operation
      SidekiqResourceGuard::Resource::Vault.add_resources(self)
    end

    def name
      "MongoDB cluster #{operation}"
    end

    def is_healthy?
      server.is_operation_safe?(@operation)
    end
  end
end