# 0.2.0

* `identifier` proc now gets called in `Grape::Attack::Request` context so that you have access to helper methods
such as `params` and Grape endpoint object.

# 0.1.1

* Support X-Real-IP for when behind loadbalancer [https://github.com/gottfrois/grape-attack/pull/3](https://github.com/gottfrois/grape-attack/pull/3)
