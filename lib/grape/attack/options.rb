require 'active_model'

module Grape
  module Attack
    class Options
      include ActiveModel::Model

      attr_accessor :max, :per, :identifier, :remaining

      validates :max, presence: true
      validates :per, presence: true

      def identifier
        @identifier || Proc.new {}
      end

    end
  end
end
