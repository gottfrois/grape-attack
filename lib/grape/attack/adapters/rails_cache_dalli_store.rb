module Grape
  module Attack
    module Adapters
      class RailsCacheDalliStore
        attr_reader :store
        def initialize
          @store = if defined?(::Rails.cache)
            unless ::Rails.cache.is_a?(::ActiveSupport::Cache::DalliStore)
              raise Grape::Attack::StoreError.new("Rails.cache is defined but isn't a Dalli store!")
            end
            ::Rails.cache
          else
            ::ActiveSupport::Cache::DalliStore.new
          end
          @cache_prefix = 'Grape::Attack'
        end

        def get(key)
          store.read(cache_key(key)).to_i
        end

        def incr(key)
          store.increment(cache_key(key))
        end

        def expire(key, ttl_in_seconds)
          store.fetch(cache_key(key), raw: true, expires_in: ttl_in_seconds) do
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
