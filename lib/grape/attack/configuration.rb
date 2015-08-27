module Grape
  module Attack
    class Configuration

      attr_accessor :adapter, :disable

      def initialize
        @adapter = ::Grape::Attack::Adapters::Redis.new
        @disable = Proc.new { false }
      end

    end
  end
end
