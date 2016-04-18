require 'active_support/core_ext/numeric/time.rb'
require 'grape/attack/version'
require 'grape/attack/configurable'
require 'grape/attack/extension'
require 'grape/attack/exceptions'
require 'grape/attack/throttle'

require 'grape/attack/adapters/memory'
require 'grape/attack/adapters/cache_memory_store'

module Grape
  module Attack
    extend Configurable
  end
end

module Grape
  module Attack
    module Adapters
      autoload :Redis, 'grape/attack/adapters/redis'
    end
  end
end
