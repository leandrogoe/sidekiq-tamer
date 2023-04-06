require "sidekiq/job_retry"

class SidekiqMongoGuard::Middleware
  class TicketsTooLowError < StandardError; end;

  def call(worker, job, queue)
    raise TicketsTooLowError if job_allows_retries?(job) && SidekiqMongoGuard::MongoClient.tickets_too_low?
    yield
  end

  def job_allows_retries?(job)
    # Retry count is handled a bit weirdly in Sidekiq:
    # retry_count = nil -> No retries actually took place
    # retry_count = 0   -> This is the first retry
    # retry_count > 0   -> This is retry_count - 1
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
end