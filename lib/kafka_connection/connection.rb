require 'kafka'

module KafkaConnection
  class Connection
    def initialize(app_name:, env_name:, pool_idx: 0)
      self.app_name = app_name
      self.env_name = env_name
      self.pool_idx = pool_idx
      check_environment!
      self.kafka_client = Kafka.new kafka_configuration
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
    attr_accessor :app_name
    attr_accessor :env_name
    attr_accessor :pool_idx

    def check_environment!
      necessary_env_vars = %w(KAFKA_BROKERS)
      if /kafka\+ssl:/.match(ENV['KAFKA_BROKERS'] || '')
        necessary_env_vars += %w(KAFKA_CA KAFKA_CERT KAFKA_PRIVATE_KEY)
      end
      missing = necessary_env_vars.reject { |var| ENV[var] }
      raise "#{missing.join(', ')} not set in the environment" unless missing.empty?
    end

    def kafka_client_id
      [app_name, env_name, Socket.gethostname, Process.pid, pool_idx].join(':')
    end

    def kafka_configuration
      {
        seed_brokers: ENV['KAFKA_BROKERS'].split(','),
        client_id: kafka_client_id,
        ssl_ca_cert: multiline_env_var('KAFKA_CA'),
        ssl_client_cert: multiline_env_var('KAFKA_CERT'),
        ssl_client_cert_key: multiline_env_var('KAFKA_PRIVATE_KEY'),
      }
    end

    # Attempts to extract multiline environment variables that have either real newlines or "\\n" as
    # line separators.
    def multiline_env_var(name)
      ENV[name].split(/\\n|\n/).join("\n") if ENV[name]
    end
  end
end
