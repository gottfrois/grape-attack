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
          adapter.get(key).to_i
        rescue ::Grape::Attack::StoreError
          1
        end
      end

      def update
        adapter.atomically do
          adapter.incr(key)
          adapter.expire(key, ttl_in_seconds)
        end
      rescue ::Grape::Attack::StoreError
      end

      private

      def key
        if request.throttle_options.global_throttling
          "#{request.client_identifier}"
        else
          "#{request.method}:#{request.path}:#{request.client_identifier}"
        end
      end

      def ttl_in_seconds
        request.throttle_options.per.to_i
      end

    end
  end
end
