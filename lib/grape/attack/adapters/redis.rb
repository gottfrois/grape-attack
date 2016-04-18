begin
   require 'redis-namespace'
rescue LoadError => e
   raise LoadError, "You are using functionality requiring the optional gem dependency `redis-namespace`, but the gem is not loaded. Add `gem 'redis-namespace'` to your Gemfile."
end

module Grape
  module Attack
    module Adapters
      class Redis

        attr_reader :broker

        def initialize
          @broker = ::Redis::Namespace.new("grape-attack:#{env}:thottle", redis: ::Redis.new(url: url))
        end

        def get(key)
          with_custom_exception do
            broker.get(key)
          end
        end

        def incr(key)
          with_custom_exception do
            broker.incr(key)
          end
        end

        def expire(key, ttl_in_seconds)
          with_custom_exception do
            broker.expire(key, ttl_in_seconds)
          end
        end

        def atomically(&block)
          broker.multi(&block)
        end

        private

        def with_custom_exception(&block)
          block.call
        rescue ::Redis::BaseError => e
          raise ::Grape::Attack::StoreError.new(e.message)
        end

        def env
          if defined?(::Rails)
            ::Rails.env
          elsif defined?(RACK_ENV)
            RACK_ENV
          else
            ENV['RACK_ENV']
          end
        end

        def url
          ENV['REDIS_URL'] || 'redis://localhost:6379/0'
        end

      end
    end
  end
end
