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
            fetch[0]
          else
            store(0)
            0
          end
        end
      end

      def update
        if adapter.key?(key)
          # Use a semaphore if it's an option for updating
          if adapter.supports?(:increment)
            Moneta::Semaphore.new(adapter, 'semaphore_counter').synchronize do
              increment
            end
          else
            increment
          end
        else
          # Key doesn't exists store as 1
          store(1)
        end
      end

      def reset
        if adapter.key?(key)
          fetch[1]
        else
          ttl_in_seconds.seconds.from_now.to_i
        end
      end

      private

      def key
        "#{request.method}:#{request.path}:#{request.client_identifier}"
      end

      def store(value, expires = ttl_in_seconds.seconds.from_now.to_i)
        adapter.store(key, "#{value}~#{expires}", expires: [0, expires - Time.now.to_i].max)

        # Reset knowledge about value
        remove_instance_variable(:@value) unless @value.nil?
      end

      def fetch
        adapter.fetch(key).split('~').map(&:to_i)
      end

      def increment
        current_value, expires = fetch
        store(current_value + 1, expires)
      end

      def ttl_in_seconds
        request.throttle_options.per.to_i
      end

    end
  end
end
