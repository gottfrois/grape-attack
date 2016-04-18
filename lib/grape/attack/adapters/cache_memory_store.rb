module Grape
  module Attack
    module Adapters
      class CacheMemoryStore
        attr_reader :store
        def initialize
          @store = ::ActiveSupport::Cache::MemoryStore.new
          @cache_prefix = 'Grape::Attack'
        end

        def get(key)
          store.read(cache_key(key)).to_i
        end

        def incr(key)
          store.fetch(cache_key(key)) do
            get(key) + 1
          end
        end

        def expire(key, ttl_in_seconds)
          store.fetch(cache_key(key), expires_in: ttl_in_seconds) do
            get(key)
          end
        end

        def atomically(&block)
          block.call
        end

        private
        def cache_key(key)
          "#{@cache_prefix}/#{key}"
        end
      end
    end
  end
end
