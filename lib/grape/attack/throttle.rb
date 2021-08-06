require 'grape/attack/limiter'

module Grape
  module Attack
    class Throttle < Grape::Middleware::Base

      def before
        ::Grape::Attack::Limiter.new(env).call!
      end

      def after
        request = ::Grape::Attack::Request.new(env)

        return if ::Grape::Attack.config.disable.call
        return unless request.throttle?

        header('X-RateLimit-Limit', request.context.route_setting(:throttle)[:max].to_s)
        header('X-RateLimit-Reset', request.context.route_setting(:throttle)[:per].to_s)
        header('X-RateLimit-Remaining', request.context.route_setting(:throttle)[:remaining].to_s)

        @app_response
      end

    end
  end
end
