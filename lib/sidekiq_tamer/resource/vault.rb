module SidekiqTamer::Resource
  class Vault
    def self.get_resources
      resources
    end

    def self.get_resources_of_type(klass)
      resources.select { |resource| resource.is_a?(klass) }
    end

    def self.resources
      @resources ||= []
    end

    def self.clean_resources
      @resources = []
    end

    def self.add_resources(*resources)
      self.resources.push(*resources)
    end

    def self.get_resources_for(job)
      get_resources.select { |resource| resource.is_consumed_by?(job) }
    end
  end
end