module SidekiqResourceGuard::Resource
  module ResourceDependencies
    def jobs
      @jobs ||= Set.new()
    end

    def add_job(job)
      jobs.add(job)
    end

    def is_consumed_by?(job)
      jobs.include?(job)
    end
  end
end