require 'active_model'

module Grape
  module Attack
    class Options
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :max, :per, :identifier, :global_throttling, :remaining

      class ProcOrNumberValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          return true if value.is_a?(Numeric)
          return true if value.is_a?(Proc) && value.call.is_a?(Numeric)

          record.errors.add attribute, "must be either a proc resolving in a numeric or a numeric"
        end
      end

      validates :max, proc_or_number: true, unless: :global_throttling
      validates :per, proc_or_number: true, unless: :global_throttling

      def identifier
        @identifier || Proc.new {}
      end

      def max
        @max = ::Grape::Attack.config.global_throttling_max if global_throttling
        return @max if @max.is_a?(Numeric)
        return @max.call if @max.is_a?(Proc)
        super
      end

      def per
        @per = ::Grape::Attack.config.global_throttling_per if global_throttling
        return @per if @per.is_a?(Numeric)
        return @per.call if @per.is_a?(Proc)
        super
      end

      def global_throttling
        return ::Grape::Attack.config.global_throttling unless @global_throttling
        @global_throttling
      end

    end
  end
end
