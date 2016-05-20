module Grape
  module Attack
    class Counter

      attr_reader :request, :adapter

      def initialize(request, adapter)
        @request = request
        @adapter = adapter
      end

      def value
        @value ||= begin
          if adapter.key?(key)
            adapter.fetch(key).to_i
          else
            # Should store it as a string so increment can be performed
            adapter.store(key, '0', expires: ttl_in_seconds)
            0
          end
        end
      end

      def update
        if adapter.supports?(:increment)
          adapter.increment(key)
        else
          # Not concerned with storing as a string as increment will never be called
          adapter.store(key, value + 1, expires: ttl_in_seconds)
        end
        remove_instance_variable(:@value)
      end

      private

      def key
        "#{request.method}:#{request.path}:#{request.client_identifier}"
      end

      def ttl_in_seconds
        request.throttle_options.per.to_i
      end

    end
  end
end
