module Grape
  module Attack
    Exceptions = Class.new(StandardError)
    RateLimitExceededError = Class.new(Exceptions)
  end
end
