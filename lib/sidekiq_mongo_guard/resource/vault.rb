require_relative 'mongo'

module SidekiqMongoGuard::Resource
  class Vault
    def self.get_resources
      [SidekiqMongoGuard::Resource::Mongo.new]
    end

    def self.get_resources_for(job)
      get_resources.select { |resource| resource.is_consumed_by?(job) }
    end
  end
end