module KafkaConnection
  class Producer
    def initialize(connection, producer)
      @kafka_connection = connection
      @kafka_producer = producer
    end

    def produce(value, **args, &block)
      args[:topic] = @kafka_connection.prefix_topic(args[:topic])
      @kafka_producer.produce(value, **args, &block)
    end

    def deliver_messages
      @kafka_producer.deliver_messages
    end
  end
end
