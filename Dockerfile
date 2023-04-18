ARG RUBY_VERSION=2.7.0

FROM ruby:$RUBY_VERSION
COPY . /sidekiq_tamer
WORKDIR /sidekiq_tamer

RUN git config --global --add safe.directory /sidekiq_tamer; \
    gem install bundler --version 2.4.10; \
    bundle install

ENTRYPOINT [ "bundle", "exec", "rspec" ]