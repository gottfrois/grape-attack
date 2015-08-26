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
        context                                = env['api.endpoint']
        @app_response['X-RateLimit-Limit']     = context.route_setting(:throttle)[:max].to_s
        @app_response['X-RateLimit-Remaining'] = context.route_setting(:throttle)[:remaining].to_s
        @app_response['X-RateLimit-Reset']     = context.route_setting(:throttle)[:per].from_now.to_i.to_s
      end

    end
  end
end
