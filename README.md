# SidekiqTamer
Do you ever worry about your Sidekiq jobs consuming too many resources, causing your system to slow down or even crash? When you don't have specific throttling requirements, SidekiqTamer can help you to easily protect your resources and prevent them from being overwhelmed by Sidekiq overscaling.

## Installation
Getting started with SidekiqTamer is a breeze. Simply add the gem to your Gemfile:

```ruby
gem 'sidekiq-tamer'
```

Then, run bundle install or gem install sidekiq-tamer to install the gem.

## Usage
With SidekiqTamer, you can delay the execution of jobs that depend on particular resources when those are on an stressed state. While SidekiqTamer was initially built to help handling the load over MongoDB, it is actually a generic framework which you can use to protect any kind of resource, such as a database or an API endpoint.

### Protecting a MongoDB cluster
SidekiqTamer includes an off-the-shelf implementation to handle MongoDB clusters. To use it, simply execute the following line during your initialization code:

```ruby
SidekiqTamer::Mongo::Configuration.setup(user: 'your_user', password: 'your_password')
```

The MongoDB monitoring relies on inspecting the read and write available tickets and whenever those are below a certain configurable threshold, the server is assumed to be on an unhealthy state and therefore jobs will be pushed back until health is recovered.

Note that in order for the health monitor to work, you'll need to supply a user that has the clusterMonitor role enabled on the admin database of your cluster.

### Defining Your Own Resources
To define a new resource, simply create a class that implements the `is_consumed_by?`, `name`, and `is_healthy?` methods. For example, if you have a database that has been hammered by background jobs in the past and you want to protect it, you might define a MyDatabaseResource class like this:

```ruby
class MyDatabaseResource
  def is_consumed_by?(job)
    true
  end

  def name
    "My Database"
  end

  def is_healthy?
    # Add some logic to assess whether it's safe to use the resource
  end
end
```

Then, add an instance of your new class to the resource vault:

```ruby
SidekiqTamer::Resource::Vault.add_resources(MyDatabaseResource.new)
```

Now, whenever the `is_healthy?` method returns false for a job that depends on this resource, the Sidekiq middleware that SidekiqTamer introduces will raise an exception, causing the job to be retried later.

## Contributing
We welcome bug reports and pull requests on GitHub at https://github.com/leandrogoe/sidekiq-tamer.

## License
SidekiqTamer is available as open source under the terms of the MIT License.
