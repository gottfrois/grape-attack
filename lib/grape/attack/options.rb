require 'active_model'

module Grape
  module Attack
    class Options
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :max, :per, :identifier, :remaining

      class ProcOrNumberValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          return true if value.is_a?(Numeric)
          return true if value.is_a?(Proc) && value.call.is_a?(Numeric)

          record.errors.add attribute, "must be either a proc resolving in a numeric or a numeric"
        end
      end

      validates :max, proc_or_number: true
      validates :per, proc_or_number: true

      def identifier
        @identifier || Proc.new {}
      end

      def max
        return @max if @max.is_a?(Numeric)
        return @max.call if @max.is_a?(Proc)
        super
      end

      def per
        return @per if @per.is_a?(Numeric)
        return @per.call if @per.is_a?(Proc)
        super
      end

    end
  end
end
