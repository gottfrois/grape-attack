require 'active_support/core_ext/numeric/time.rb'
require 'moneta'
require 'grape/attack/version'
require 'grape/attack/configurable'
require 'grape/attack/extension'
require 'grape/attack/exceptions'
require 'grape/attack/throttle'

module Grape
  module Attack
    extend Configurable

    private
    def adapter
      @adapter ||= Moneta.new(config.adapter).raw
    end
  end
end
