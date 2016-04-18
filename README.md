[![Code Climate](https://codeclimate.com/github/gottfrois/grape-attack/badges/gpa.svg)](https://codeclimate.com/github/gottfrois/grape-attack)

# Grape::Attack

A middleware for Grape to add endpoint-specific throttling.

## Why

You are probably familiar with [Rack::Attack](https://github.com/kickstarter/rack-attack) which does a great job. Grape::Attack was built with simplicity in mind. It was also built to be used directly in [Grape](https://github.com/ruby-grape/grape) APIs without any special configurations.

It comes with a little DSL that allows you to protect your Grape API endpoints. It also automaticaly sets custom HTTP headers to let your clients know how much requests they have left.

If you need more advanced feature like black and white listing, you should probably use [Rack::Attack](https://github.com/kickstarter/rack-attack). But if you simply want to do API throttling for each of your Grape endpoints, go ahead and continue reading.

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

---

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

---

By default requests to each endpoint's methods will be counted separately, if you would like the requests to the method to be counted for and checked against a global total, you can specify `global_throttling: true`. When `global_throttling` is set to true, `max` and `per` are ignored on the endpoint and instead, `global_throttling_max`, and `global_throttling_per` from the [configuration](#configuration) are looked at.

> `global_throttling` can also be set to true in the [Grape::Attack configuration](#configuration).

```ruby
class MyApi < Grape::API

  use Grape::Attack::Throttle

  helpers do
    def current_user
      @current_user ||= User.authorize!(env)
    end
  end

  resources :comments do

    throttle global_throttling: true
    get do
      Comment.all
    end

  end
end
```

---

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

---

Finally the following headers will automatically be set:

* `X-RateLimit-Limit` -- The maximum number of requests that the consumer is permitted to make per specified period.
* `X-RateLimit-Remaining` -- The number of requests remaining in the current rate limit window.
* `X-RateLimit-Reset` -- The time at which the current rate limit window resets in [UTC epoch seconds](https://en.wikipedia.org/wiki/Unix_time).

## Adapters

Adapters are used to store the rate counter.
Currently there is only a Redis adapter. You can set redis client url through `env['REDIS_URL']` varialble.

Defaults to `redis://localhost:6379/0`.

## Configuration

If you wish to set a different [adapter](#adapters) or provide configuration options for `global_throttling`, you can configure `Grape::Attack` in a Rails initializer.

```ruby
# config/initializers/grape_attack.rb

Grape::Attack.configure do |c|
  c.adapter = Grape::Attack::Adapters::Memory.new  # defaults to Grape::Attack::Adapters::Redis.new
  c.global_throttling = true                       # defaults to false
  c.global_throttling_max = 1000                   # defaults to 500
  c.global_throttling_per = 1.day                  # defaults to 1.day
end     
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/grape-attack.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
