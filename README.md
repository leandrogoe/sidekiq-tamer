# Sidekiq Resource Guard
Do you ever worry about your Sidekiq jobs consuming too many resources, causing your system to slow down or even crash? With Sidekiq Resource Guard, you can easily protect your resources and prevent them from being overwhelmed.

## Installation
Getting started with Sidekiq Resource Guard is a breeze. Simply add the gem to your Gemfile:

```ruby
gem 'sidekiq-resource-guard'
```

Then, run bundle install or gem install sidekiq-resource-guard to install the gem.

## Usage
With Sidekiq Resource Guard, you can delay the execution of jobs that depend on particular resources until those resources are in a healthy state. You can even define your own resources to protect, such as a database or an API endpoint.

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
SidekiqResourceGuard::Resource::Vault.add_resources(MyDatabaseResource.new)
```

Now, whenever the `is_healthy?` method returns false for a job that depends on this resource, the Sidekiq middleware that Sidekiq Resource Guard introduces will raise an exception, causing the job to be retried later.

### Protecting a MongoDB cluster
Sidekiq Resource Guard includes an off-the-shelf implementation for MongoDB clusters. To use it, simply execute the following line during your code initialization:

```ruby
SidekiqResourceGuard::Mongo::Configuration.setup(user: 'your_user', password: 'your_password')
```
Note that in order for the health monitor to work, you'll need to supply a user that has the clusterMonitor role enabled on the admin database of your cluster.

## Contributing
We welcome bug reports and pull requests on GitHub at https://github.com/leandrogoe/sidekiq-resource-guard.

## License
Sidekiq Resource Guard is available as open source under the terms of the MIT License.