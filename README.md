[![Build Status](https://travis-ci.org/omniboard/kafka_connection-ruby.svg?branch=master)](https://travis-ci.org/omniboard/kafka_connection-ruby)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d190161ce0a14b9eaf1e78faa7c4f2f1)](https://www.codacy.com/app/Omniboard/kafka_connection-ruby?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=omniboard/kafka_connection-ruby&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/d190161ce0a14b9eaf1e78faa7c4f2f1)](https://www.codacy.com/app/Omniboard/kafka_connection-ruby?utm_source=github.com&utm_medium=referral&utm_content=omniboard/kafka_connection-ruby&utm_campaign=Badge_Coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/omniboard/kafka_connection-ruby.svg)](https://gemnasium.com/github.com/omniboard/kafka_connection-ruby)

# kafka_connection

A standard way to connect to Kafka to consume and produce.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kafka_connection'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kafka_connection

## Usage

This gem requires the following environment variables:

- `KAFKA_BROKERS`: Comma-separated list of brokers. E.g. "kafka+ssl://hostname:9092"
- `KAFKA_CA`: The CA certificate in PEM format.
- `KAFKA_CERT`: The client's certificate in PEM format.
- `KAFKA_PRIVATE_KEY`: The client's private key in PEM format.

The PEM-format keys are multi-line values and must not have their lines concatenated.
If your environment does not make it easy to set variables containing newlines, you can use the string "\n" (acually containing a backslash) in place of newline characters.

- `KAFKA_TOPIC_PREFIX`: Optional. If present, any topic names used with the consumer or producer will be prefixed with this string.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

