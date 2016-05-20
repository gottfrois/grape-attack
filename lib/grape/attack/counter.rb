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
            adapter.fetch(key)
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

        # Reset knowledge about value
        remove_instance_variable(:@value)
      end

      def reset
        if adapter.key?(key)
          get_raw[1]
        else
          ttl_in_seconds.from_now.to_i
        end
      end

      private

      def key
        "#{request.method}:#{request.path}:#{request.client_identifier}"
      end

      def store(value)
        if adapter.supports?(:create)
          adapter.create(key, value, expires: ttl_in_seconds)
        else
          adapter.store(key, value, expires: ttl_in_seconds)
        end
      end

      def increment
        current_value, expires = get_raw
        store_raw(current_value.to_i + 1, expires)
      end

      def get_raw
        adapter.raw.fetch(key).gsub(/[\[\]]/, '').split(',')
      end

      def store_raw(new_value, exp)
        adapter.raw.store(key, "[#{new_value},#{exp}]")
      end

      def ttl_in_seconds
        request.throttle_options.per.to_i
      end

    end
  end
end
