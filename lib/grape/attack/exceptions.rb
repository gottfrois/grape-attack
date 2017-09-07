module Grape
  module Attack
    StoreError = Class.new(StandardError)
    Exceptions = Class.new(StandardError)

    class RateLimitExceededError < Exceptions
      attr_reader :client_identifier

      def initialize(msg = nil, client_identifier: nil)
        @client_identifier = client_identifier

        return super(msg) if msg

        msg = 'API rate limit exceeded'
        super(client_identifier ? "#{msg} for #{client_identifier}" : msg)
      end
    end
  end
end
