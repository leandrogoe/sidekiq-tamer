# Sidekiq Resource Guard

A simple way to protect your resources from excessive Sidekiq scaling.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-resource-guard'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sidekiq-resource-guard

## Usage

With the help of this gem you can push back the execution of your jobs whenever the resources they depend on are considerd to be on an unhealthy state. The concept of resource is rather generic and you can provide your own implementation of whatever resource you like, such a database or an API endpoint. We also provide a library to manage a few specific resources that you can simply drop-in your code.

### Implementing your own resource

Let's say you have a resource which you know has been hammered by your background jobs in the past and you want to prevent this from happening in the future. For the sake of having a simple example, let's say we are talking about a database and we can call it "my database". Then the only thing you would need to do is declare a class that implements the interface described above and then add an instance to the resource vault:

```
   class MyDatabaseResource
    def is_consumed_by?(job)
      true
    end

    def name
      "My Database"
    end

    def is_healthy?
      # Add some logic to assess it is safe to use the resource
    end
   end
```

```
   SidekiqResourceGuard::Resource::Vault.add_resources(MyDatabaseResource.new)
```

That's it! Whenever the `is_healthy?` method returns `false` for a job that consumes this resource (see `is_consumed_by?` method), the Sidekiq middleware that this gem introduces will raise an exception forcing the job to be retried later on.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sidekiq-resource-guard.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
