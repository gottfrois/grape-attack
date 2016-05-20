module Grape
  module Attack
    class Configuration

      attr_accessor :adapter, :disable

      def initialize
        @adapter = :Memory
        @disable = Proc.new { false }
      end

    end
  end
end
