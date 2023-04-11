module SidekiqResourceGuard::Mongo
  class MongoCommandSubscriber
    # https://github.com/mongodb/mongo-ruby-driver/blob/413555d553148d8bbf8bea2855cbd9929f3ba587/docs/reference/monitoring.txt#L27

    DATA_MODIFICATION_COMMANDS=Set.new([
      'insert',
      'delete',
      'replace',
      'update',
      'drop',
      'rename',
      'dropDatabase',
      'invalidate',
      'createIndexes',
      'dropIndexes',
      'create',
      'modify',
      'shardCollection',
    ]).freeze

    def started(event)
      unless event.command.keys.any?
        return
      end

      operation = event.command.keys.any? { |key| DATA_MODIFICATION_COMMANDS.include?(key) } ? :write : :read
      mongo_server_operation = SidekiqResourceGuard::Mongo::MongoServerOperation.server_operation_for(
        event.address.host, event.address.port, operation
      )
      if job_name = Thread.current[:sidekiq_resource_guard_job_name]
        mongo_server_operation.add_job(Object.const_get(job_name))
      end
    end

    def succeeded(event)
      # No implementation, just provided to fullfil the expected interface.
    end

    def failed(event)
      # No implementation, just provided to fullfil the expected interface.
    end
  end
end

