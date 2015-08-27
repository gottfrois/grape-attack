require 'grape/attack/configuration'

module Grape
  module Attack
    module Configurable

      def config
        @config ||= ::Grape::Attack::Configuration.new
      end

      def configure
        yield config if block_given?
      end

    end
  end
end
