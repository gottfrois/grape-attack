module Grape
  module Attack
    class Configuration

      attr_accessor :adapter, :disable

      def initialize
        @adapter = :Memory
        @disable = Proc.new { false }
      end

      def moneta_adapter
        @moneta_adapter ||= Moneta.new(adapter, expires: true, serializer: :json)
      end
    end
  end
end
