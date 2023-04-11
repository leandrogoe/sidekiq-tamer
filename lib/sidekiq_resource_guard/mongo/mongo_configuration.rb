module SidekiqResourceGuard::Mongo
  class MongoConfiguration
    MIN_TICKET_THRESHOLD = 80

    class << self
      def setup(user:, password:, ticket_threshold: MIN_TICKET_THRESHOLD)
        @options = { user: user, password: password, ticket_threshold: ticket_threshold }
        subscriber = SidekiqResourceGuard::Mongo::MongoCommandSubscriber.new
        ::Mongo::Monitoring::Global.subscribe(::Mongo::Monitoring::COMMAND, subscriber)
      end

      def clear()
        ::Mongo::Monitoring::Global.unsubscribe(::Mongo::Monitoring::COMMAND, self)
        @options = {}
      end

      def user
        get_option_value(:user)
      end

      def password
        get_option_value(:password)
      end

      def ticket_threshold
        get_option_value(:ticket_threshold)
      end

    private

      def get_option_value(option)
        if @options[option].is_a?(Proc)
          @options[option].call()
        else
          @options[option]
        end
      end
    end
  end
end