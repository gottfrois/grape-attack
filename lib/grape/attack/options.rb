require 'active_model'

module Grape
  module Attack
    class Options
      include ActiveModel::Model

      attr_accessor :max, :per, :identifier, :global_throttling, :remaining

      validates :max, presence: true, unless: :global_throttling
      validates :per, presence: true, unless: :global_throttling

      def identifier
        @identifier || Proc.new {}
      end

      def max
        global_throttling ? ::Grape::Attack.config.global_throttling_max : @max
      end

      def per
        global_throttling ? ::Grape::Attack.config.global_throttling_per : @per
      end

      def global_throttling
        @global_throttling.nil? ? ::Grape::Attack.config.global_throttling : @global_throttling
      end
    end
  end
end
