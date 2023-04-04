module Sidekiq::Mongo::Guard::Middleware
  MIN_TICKET_THRESHOLD = 80

  class TicketsTooLowError < StandardError; end;

  def initialize(optional_args)
    @args = optional_args
  end

  def call(worker, job, queue)
    raise TicketsTooLowError if tickets_too_low?
    yield
  end

  def tickets_too_low?
    wiredtiger_tickets["write"]["available"] < MIN_TICKET_THRESHOLD || wiredtiger_tickets["read"]["available"] < MIN_TICKET_THRESHOLD
  end

  def wiredtiger_tickets
    @wiredtiger_tickets_read_at ||= Time.now
    if @wiredtiger_tickets_read_at < 1.minutes.ago
      @wiredtiger_tickets = Mongoid::Clients.default.database.command('serverStatus'=> 1).documents[0]['wiredTiger']['concurrentTransactions']
    end
    @wiredtiger_tickets
  end
end