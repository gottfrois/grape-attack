require 'grape/attack/adapters/redis'
require 'grape/attack/request'
require 'grape/attack/counter'

module Grape
  module Attack
    class Limiter

      attr_reader :request, :adapter, :counter

      def initialize(env, adapter = ::Grape::Attack::Adapters::Redis.new)
        @request = ::Grape::Attack::Request.new(env)
        @adapter = adapter
        @counter = ::Grape::Attack::Counter.new(@request, @adapter)
      end

      def call!
        if allowed?
          update_counter
          set_rate_limit_headers
        else
          fail ::Grape::Attack::RateLimitExceededError.new("API rate limit exceeded for #{request.client_identifier}.")
        end
      end

      private

      def allowed?
        counter.value < max_requests_allowed
      end

      def update_counter
        counter.update
      end

      # Fix when https://github.com/ruby-grape/grape/issues/1069
      # For now we use route_setting to store :remaining value.
      def set_rate_limit_headers
        request.context.route_setting(:throttle)[:remaining] = [0, max_requests_allowed - (counter.value + 1)].max
      end

      def max_requests_allowed
        request.throttle_options.max.to_i
      end

    end
  end
end
