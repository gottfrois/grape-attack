module Grape
  module Attack
    module Adapters
      class Memory

        attr_reader :data

        def initialize
          @data = {}
        end

        def get(key)
          data[key]
        end

        def incr(key)
          data[key] ||= 0
          data[key] += 1
        end

        def expire(key, ttl_in_seconds)
        end

        def atomically(&block)
          block.call
        end

      end
    end
  end
end
