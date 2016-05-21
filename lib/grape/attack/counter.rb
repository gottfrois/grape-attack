module Grape
  module Attack
    class Counter

      attr_reader :request, :adapter

      def initialize(request, adapter)
        @request = request
        @adapter = adapter
      end

      def value
        fetch[0]
      end

      def update
        adapter.atomically do
          value, exp = fetch
          store(value + 1, exp)
        end
      rescue ::Grape::Attack::StoreError
      end

      private

      def key
        "#{request.method}:#{request.path}:#{request.client_identifier}"
      end

      def store(value, exp)
        adapter.atomically do
          adapter.set(key, "#{value}~#{exp}")
          adapter.expire(key, [0, exp - Time.now.to_i].max)
        end
        remove_instance_variable(:@raw_value) unless @raw_value.nil?
      end

      def fetch
        @raw_value ||= begin
          adapter.get(key).split('~').map(&:to_i)
        rescue ::Grape::Attack::StoreError, NoMethodError
          [0, ttl_in_seconds.seconds.from_now.to_i]
        end
      end

      def ttl_in_seconds
        request.throttle_options.per.to_i
      end

    end
  end
end
