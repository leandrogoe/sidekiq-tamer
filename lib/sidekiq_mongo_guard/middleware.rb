require "sidekiq/job_retry"

class SidekiqMongoGuard::Middleware
  MIN_TICKET_THRESHOLD = 80

  class TicketsTooLowError < StandardError; end;

  def call(worker, job, queue)
    raise TicketsTooLowError if job_allows_retries?(job) && tickets_too_low?
    yield
  end

  def job_allows_retries?(job)
    (job["retry_count"] || -1) + 1 < max_retries_for(job)
  end

  def max_retries_for(job)
    if job["retry"] == true || job["retry"] == nil
      Sidekiq.options[:max_retries] || Sidekiq::JobRetry::DEFAULT_MAX_RETRY_ATTEMPTS
    elsif job["retry"] == false
      0
    elsif job["retry"].is_a?(Integer)
      job["retry"]
    else
      raise StandardError, "Unrecognized retry option"
    end
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