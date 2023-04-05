class SidekiqMongoGuard::Middleware
  MIN_TICKET_THRESHOLD = 80

  class TicketsTooLowError < StandardError; end;

  def call(worker, job, queue)
    raise TicketsTooLowError if tickets_too_low?
    yield
  end

  def tickets_too_low?
    wiredtiger_tickets["write"]["available"] < MIN_TICKET_THRESHOLD || wiredtiger_tickets["read"]["available"] < MIN_TICKET_THRESHOLD
  end

  def wiredtiger_tickets
    if !@wiredtiger_tickets_read_at || @wiredtiger_tickets_read_at < Time.now - 60
      @wiredtiger_tickets = SidekiqMongoGuard::MongoClient.available_tickets
      @wiredtiger_tickets_read_at ||= Time.now
    end
    @wiredtiger_tickets
  end
end