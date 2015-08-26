module Grape
  module Attack
    StoreError = Class.new(StandardError)
    Exceptions = Class.new(StandardError)
    RateLimitExceededError = Class.new(Exceptions)
  end
end
