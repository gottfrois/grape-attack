require 'grape'
require 'grape/attack/limiter'

module Grape
  module Attack
    class Throttle < Grape::Middleware::Base

      def before
        ::Grape::Attack::Limiter.new(env).call!
      end

      # Fix when https://github.com/ruby-grape/grape/issues/1069
      # For now we use route_setting to store :remaining value.
      def after
        request = ::Grape::Attack::Request.new(env)

        return if ::Grape::Attack.config.disable.call
        return unless request.throttle?

        @app_response['X-RateLimit-Limit']     = request.context.route_setting(:throttle)[:max].to_s
        @app_response['X-RateLimit-Remaining'] = request.context.route_setting(:throttle)[:remaining].to_s
        @app_response['X-RateLimit-Reset']     = request.context.route_setting(:throttle)[:reset].to_s
        @app_response
      end

    end
  end
end
