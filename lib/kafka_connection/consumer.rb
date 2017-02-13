module KafkaConnection
  class Consumer
    def initialize(connection, consumer)
      @kafka_connection = connection
      @kafka_consumer = consumer
    end

    def subscribe(topic, **args, &block)
      topic = @kafka_connection.prefix_topic(topic)
      @kafka_consumer.subscribe(topic, **args, &block)
    end

    def stop
      @kafka_consumer.stop
    end

    def method_missing(method_name, **args, &block)
      @kafka_consumer.send(method_name, **args, &block)
    end

    def respond_to?(method_name)
      @kafka_consumer.respond_to?(method_name) || super
    end
  end
end
