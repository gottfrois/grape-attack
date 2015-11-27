require 'grape/attack/options'

module Grape
  module Attack
    class Request

      attr_reader :env, :context, :request, :throttle_options

      def initialize(env)
        @env              = env
        @context          = env['api.endpoint']
        @request          = @context.routes.first
        @throttle_options = ::Grape::Attack::Options.new(@context.route_setting(:throttle))
      end

      def method
        request.route_method
      end

      def path
        request.route_path
      end

      def params
        request.route_params
      end

      def client_identifier
        self.instance_eval(&throttle_options.identifier) || env['HTTP_X_REAL_IP'] || env['REMOTE_ADDR']
      end

      def throttle?
        return false unless context.route_setting(:throttle).present?
        return true if throttle_options.valid?

        fail ArgumentError.new(throttle_options.errors.full_messages)
      end

    end
  end
end
