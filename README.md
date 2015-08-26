[![Code Climate](https://codeclimate.com/github/gottfrois/grape-attack/badges/gpa.svg)](https://codeclimate.com/github/gottfrois/grape-attack)

# Grape::Attack

A middleware for Grape to add endpoint-specific throttling.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-attack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape-attack

## Usage

Mount the middleware in your API:

```ruby
class MyApi < Grape::API
  use Grape::Attack::Throttle
end
```

Define limits per endpoints using `throttle` DSL:

```ruby
class MyApi < Grape::API

  use Grape::Attack::Throttle

  resources :comments do

    throttle max: 10, per: 1.minute
    get do
      Comment.all
    end

  end
end
```

Use any [ActiveSupport Time extension to Numeric](http://edgeguides.rubyonrails.org/active_support_core_extensions.html#time) object.

By default it will use the request ip address to identity the client making the request.
You can pass your own identifier using a `Proc`:

```ruby
class MyApi < Grape::API

  use Grape::Attack::Throttle

  helpers do
    def current_user
      @current_user ||= User.authorize!(env)
    end
  end

  resources :comments do

    throttle max: 100, per: 1.day, identifier: Proc.new { current_user.id }
    get do
      Comment.all
    end

  end
end
```

When rate limit is reached, it will raise `Grape::Attack::RateLimitExceededError` exception.
You can catch the exception using `rescue_from`:

```ruby
class MyApi < Grape::API

  use Grape::Attack::Throttle

  rescue_from Grape::Attack::RateLimitExceededError do |e|
    error!({ message: e.message }, 403)
  end

  resources :comments do

    throttle max: 100, per: 1.day
    get do
      Comment.all
    end

  end
end
```

Which would result in the following http response:

```
HTTP/1.1 403 Forbidden
Content-Type: application/json

{"message":"API rate limit exceeded for xxx.xxx.xxx.xxx."}
```

Finally the following headers will automatically be set:

* `X-RateLimit-Limit` -- The maximum number of requests that the consumer is permitted to make per specified period.
* `X-RateLimit-Remaining` -- The number of requests remaining in the current rate limit window.
* `X-RateLimit-Reset` -- The time at which the current rate limit window resets in [UTC epoch seconds](https://en.wikipedia.org/wiki/Unix_time).

## Adapters

Adapters are used to store the rate counter.
Currently there is only a Redis adapter. You can set redis client url through `env['REDIS_URL']` varialble.

Defaults to `redis://localhost:6379/0`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/grape-attack.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

