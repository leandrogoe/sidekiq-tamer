FROM ruby:3.0
COPY . /sidekiq_resource_guard
WORKDIR /sidekiq_resource_guard

RUN gem install bundler --version 2.4.10; bundle install

ENTRYPOINT [ "bundle", "exec", "rspec" ]