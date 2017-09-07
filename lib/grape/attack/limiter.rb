require 'grape/attack/request'
require 'grape/attack/counter'

module Grape
  module Attack
    class Limiter

      attr_reader :request, :adapter, :counter

      def initialize(env, adapter = ::Grape::Attack.config.adapter)
        @request = ::Grape::Attack::Request.new(env)
        @adapter = adapter
        @counter = ::Grape::Attack::Counter.new(@request, @adapter)
      end

      def call!
        return if disable?
        return unless throttle?

        if allowed?
          update_counter
          set_rate_limit_headers
        else
          fail ::Grape::Attack::RateLimitExceededError.new(client_identifier: request.client_identifier)
        end
      end

      private

      def disable?
        ::Grape::Attack.config.disable.call
      end

      def throttle?
        request.throttle?
      end

      def allowed?
        counter.value < max_requests_allowed
      end

      def update_counter
        counter.update
      end

      def set_rate_limit_headers
        request.context.route_setting(:throttle)[:remaining] = [0, max_requests_allowed - (counter.value + 1)].max
      end

      def max_requests_allowed
        request.throttle_options.max.to_i
      end

    end
  end
end
