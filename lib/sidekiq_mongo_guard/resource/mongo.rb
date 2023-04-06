require 'mongoid'

module SidekiqMongoGuard::Resource
  class Mongo
    MIN_TICKET_THRESHOLD = 80

    def name
      "MongoDB cluster"
    end

    def is_consumed_by?(job)
      true
    end

    def is_healthy?
      !self.class.tickets_too_low?
    end

    def self.tickets_too_low?
      wiredtiger_tickets["write"]["available"] < MIN_TICKET_THRESHOLD || wiredtiger_tickets["read"]["available"] < MIN_TICKET_THRESHOLD
    end

    def self.wiredtiger_tickets
      if !@wiredtiger_tickets_read_at || @wiredtiger_tickets_read_at < Time.now - 60
        @wiredtiger_tickets = available_tickets
        @wiredtiger_tickets_read_at ||= Time.now
      end
      @wiredtiger_tickets
    end

    def self.available_tickets
      Mongoid::Clients.default.database.command('serverStatus'=> 1).documents[0]['wiredTiger']['concurrentTransactions']
    end

    def self.clean_wired_tiger_tickets
      @wiredtiger_tickets_read_at = nil
    end
  end
end