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

        header('X-RateLimit-Limit', request.throttle_options.max.to_s)
        header('X-RateLimit-Reset', request.throttle_options.per.to_s)
        header('X-RateLimit-Remaining', request.throttle_options.remaining.to_s)

        @app_response
      end

    end
  end
end
