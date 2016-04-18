module Grape
  module Attack
    class Configuration

      attr_accessor :adapter, :disable, :global_throttling, :global_throttling_max, :global_throttling_per

      def initialize
        @adapter = ::Grape::Attack::Adapters::Redis.new
        @disable = Proc.new { false }
        @global_throttling = false
        @global_throttling_max = 500
        @global_throttling_per = 1.day
      end

    end
  end
end
