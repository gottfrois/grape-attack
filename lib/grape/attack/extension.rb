module Grape
  module Attack
    module Extension

      def throttle(options = {})
        route_setting(:throttle, options)
        options
      end

      # Grape::API::Instance is defined in grape 1.2.0 or above
      grape_api = defined?(::Grape::API::Instance) ? ::Grape::API::Instance : ::Grape::API
      grape_api.extend self

    end
  end
end
