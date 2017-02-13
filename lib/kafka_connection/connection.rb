require 'kafka'

module KafkaConnection
  class Connection
    def initialize(app_name:, env_name:, pool_idx: 0)
      missing = %w(KAFKA_BROKERS KAFKA_CA KAFKA_CERT KAFKA_PRIVATE_KEY).reject { |var|
        ENV[var]
      }
      raise "#{missing.join(', ')} not set in the environment" unless missing.empty?

      self.kafka_client = Kafka.new(
        seed_brokers: ENV['KAFKA_BROKERS'].split(','),
        client_id: [app_name, env_name, Socket.gethostname, Process.pid, pool_idx].join(':'),
        ssl_ca_cert: multiline_env_var('KAFKA_CA'),
        ssl_client_cert: multiline_env_var('KAFKA_CERT'),
        ssl_client_cert_key: multiline_env_var('KAFKA_PRIVATE_KEY'),
      )
    end

    def prefix_topic(topic)
      "#{ENV['KAFKA_TOPIC_PREFIX']}#{topic}"
    end

    def producer
      KafkaConnection::Producer.new(self, kafka_client.producer(compression_codec: :gzip))
    end

    def consumer(**args, &block)
      KafkaConnection::Consumer.new(self, kafka_client.consumer(**args, &block))
    end

    private

    attr_accessor :kafka_client

    # Attempts to extract multiline environment variables that have either real newlines or "\\n" as
    # line separators.
    def multiline_env_var(name)
      ENV[name].split(/\\n|\n/).join("\n")
    end
  end
end
