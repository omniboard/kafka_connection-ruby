[![Build Status](https://travis-ci.org/omniboard/kafka_connection-ruby.svg?branch=master)](https://travis-ci.org/omniboard/kafka_connection-ruby)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d190161ce0a14b9eaf1e78faa7c4f2f1)](https://www.codacy.com/app/Omniboard/kafka_connection-ruby?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=omniboard/kafka_connection-ruby&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/d190161ce0a14b9eaf1e78faa7c4f2f1)](https://www.codacy.com/app/Omniboard/kafka_connection-ruby?utm_source=github.com&utm_medium=referral&utm_content=omniboard/kafka_connection-ruby&utm_campaign=Badge_Coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/omniboard/kafka_connection-ruby.svg)](https://gemnasium.com/github.com/omniboard/kafka_connection-ruby)

# kafka_connection

A standard way to connect to Kafka to consume and produce.

## Installation

### Authenticating

This is a private gem, so it is not hosted on [fury.io](https://fury.io).

#### As a developer

As a developer, you will need to create an account on fury.io and be added to the organization.
Get your repo access token [from the management site](https://manage.fury.io/dashboard/omniboard/repos?kind=ruby), and configure Bundler to use it:

```sh
bundle config https://gem.fury.io/omniboard/ PeRSonAl-SeCrEt-ToKeN
```

#### For deployment or CI

Get the organization's account access token [from the management site](https://manage.fury.io/manage/omniboard/settings/), and configure the environment on CI or an application:

```sh
export BUNDLE_GEM__FURY__IO=PeRSonAl-SeCrEt-ToKeN
```

### In a new application
Add this to your application's Gemfile, then run `bundle`:

```rb
source "https://gem.fury.io/omniboard/" do
  gem 'kafka_connection'
end
```

_Never_ place a repository access token in the Gemfile, or commit it to the repo anywhere else. The default instructions that Gemfury provides do this, but we use the [instructions for Bundler 1.8+](https://gemfury.com/help/install-gems#keep-your-privates-private-bundler-18).

## Usage

This gem requires the following environment variables:

- `KAFKA_BROKERS`: Comma-separated list of brokers. E.g. "kafka+ssl://hostname:9092"
- `KAFKA_CA`: The CA certificate in PEM format.
- `KAFKA_CERT`: The client's certificate in PEM format.
- `KAFKA_PRIVATE_KEY`: The client's private key in PEM format.

The PEM-format keys are multi-line values and must not have their lines concatenated.
If your environment does not make it easy to set variables containing newlines, you can use the string "\n" (acually containing a backslash) in place of newline characters.

- `KAFKA_TOPIC_PREFIX`: Optional. If present, any topic names used with the consumer or producer will be prefixed with this string.

To create a connection to Kafka:
```rb
  kafka_connection = KafkaConnection.new(
    app_name: "my_great_project", # Used as part of the Kafka client identifier
    env_name: Rails.env.to_s.downcase,
  )
```

To produce:
```rb
  kafka_producer = kafka_connection.producer
  kafka_producer.produce("My great log entry", topic: "topic-name")
  kafka_producer.deliver_messages

  # Or use a pool of connections:
  # (in config/initializers/kafka.rb):
  max_threads = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
  $kafka_connection_pool = KafkaConnection.pool(
    size: max_threads,
    timeout: 5,
    app_name: "my_great_project",
    env_name: Rails.env.to_s.downcase,
  )

  # (anywhere in the project):
  $kafka_connection_pool.with do |kafka_connection|
    kafka_producer = kafka_connection.producer
    kafka_producer.produce("My great log entry", topic: "topic-name")
    kafka_producer.deliver_messages
  end
```

To consume:
```rb
  # `group_id` is the consumer group name; multiple processes with the same value will
  # share the topic(s) (and each get different partitions).
  kafka_consumer = kafka_connection.consumer(group_id: "#{Rails.env.to_s.downcase.downcase}.#{self.class.name}")
  kafka_consumer.subscribe "topic-name"
  kafka_consumer.each_message do |message|
    process_message(message)
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

