require "spec_helper"
require 'kafka_connection'

RSpec.describe KafkaConnection do
  after do
    ENV.delete 'KAFKA_BROKERS'
    ENV.delete 'KAFKA_CA'
    ENV.delete 'KAFKA_CERT'
    ENV.delete 'KAFKA_PRIVATE_KEY'
  end

  it "has a version number" do
    expect(KafkaConnection::VERSION).not_to be nil
  end

  subject(:instance) {
    described_class.new(app_name: app_name, env_name: env_name, pool_idx: pool_idx)
  }
  let(:app_name) { "app_22_is_great_app" }
  let(:env_name) { "test" }
  let(:pool_idx) { 12 }

  context 'when KAFKA_BROKERS and other required environment variables are set' do
    before do
      ENV['KAFKA_BROKERS'] = "host1:123,host2:234"
      ENV['KAFKA_CA'] = "-----BEGIN CA CERTIFICATE-----\nabcd\n---END---"
      ENV['KAFKA_CERT'] = "-----BEGIN CERTIFICATE-----\\nabcd\\n---END---"
      ENV['KAFKA_PRIVATE_KEY'] = "CERT_KEY"
    end

    before do
      allow(Kafka).to receive(:new).and_return(kafka_client)
    end
    let(:kafka_client) {
      double('kafka', producer: kafka_producer, consumer: kafka_consumer)
    }
    let(:kafka_producer) {
      double('kafka_producer', produce: nil, deliver_messages: nil)
    }
    let(:kafka_consumer) {
      double('kafka_consumer', subscribe: nil)
    }

    describe '#new' do
      it 'creates a Kafka object' do
        expect(Kafka).to receive(:new).with(
          seed_brokers: ['host1:123', 'host2:234'],
          client_id:
            "app-22-is-great-app_#{env_name}_#{Socket.gethostname}_#{Process.pid}_#{pool_idx}",
          ssl_ca_cert: "-----BEGIN CA CERTIFICATE-----\nabcd\n---END---",
          ssl_client_cert: "-----BEGIN CERTIFICATE-----\nabcd\n---END---",
          ssl_client_cert_key: 'CERT_KEY',
        )
        instance
      end
    end

    describe '#pool' do
      let(:pool) { described_class.pool(app_name: app_name, env_name: env_name, size: 2) }
      describe '#with' do
        it 'yields a new Connection' do
          expect(KafkaConnection::Connection).to receive(:new)
            .with(app_name: app_name, env_name: env_name, pool_idx: 1)
            .and_return(:connection)
          expect { |b| pool.with(&b) }.to yield_with_args(:connection)
        end
        context 'when called a second time' do
          it 'yields the same Connection' do
            expect(KafkaConnection::Connection).to receive(:new)
              .with(app_name: app_name, env_name: env_name, pool_idx: 1).once
              .and_return(:connection)
            expect { |b| pool.with(&b) }.to yield_with_args(:connection)
            expect { |b| pool.with(&b) }.to yield_with_args(:connection)
          end
          context 'before the first connection is released' do
            it 'creates another connection with an increased pool_idx' do
              allow(KafkaConnection::Connection).to receive(:new)
                .with(app_name: app_name, env_name: env_name, pool_idx: 1)
                .and_return(:connection1)
              allow(KafkaConnection::Connection).to receive(:new)
                .with(app_name: app_name, env_name: env_name, pool_idx: 2)
                .and_return(:connection2)
              @still_waiting = true
              t = Thread.new do
                pool.with do |c|
                  while @still_waiting
                    sleep 0.5
                  end
                end
              end
              sleep 1
              expect { |b| pool.with(&b) }.to yield_with_args(:connection2)
              @still_waiting = false
              t.join
            end
          end
        end
      end
    end

    describe '#producer' do
      it 'instantiates a Kafka producer' do
        expect(kafka_client).to receive(:producer)
        instance.producer
      end

      it 'returns an object that responds to "produce" and "deliver_messages"' do
        expect(instance.producer).to respond_to(:produce)
        expect(instance.producer).to respond_to(:deliver_messages)
      end

      describe '#produce' do
        let(:producer) { instance.producer }

        it 'calls produce on the kafka producer' do
          expect(kafka_producer).to receive(:produce).with("value", topic: "topic")
          producer.produce("value", topic: "topic")
        end

        context 'with a topic prefix configured' do
          before do
            ENV['KAFKA_TOPIC_PREFIX'] = "PREFIX"
          end
          after do
            ENV.delete 'KAFKA_TOPIC_PREFIX'
          end

          it 'calls produce on the kafka producer with the topic name prefixed' do
            expect(kafka_producer).to receive(:produce).with("value", topic: "PREFIXtopic")
            producer.produce("value", topic: "topic")
          end
        end
      end

      describe '#deliver_messages' do
        let(:producer) { instance.producer }

        it 'calls deliver_messages on the kafka producer' do
          expect(kafka_producer).to receive(:deliver_messages)
          producer.deliver_messages
        end

        context 'when there is a failure' do
          before do
            allow(kafka_producer).to receive(:deliver_messages)
              .and_raise(Kafka::DeliveryFailed, "Nope!")
          end

          it 'raises DeliveryFailed' do
            expect { producer.deliver_messages }.to raise_error(Kafka::DeliveryFailed)
          end
        end
      end
    end

    describe '#consumer' do
      it 'instantiates a Kafka consumer' do
        expect(kafka_client).to receive(:consumer).with(group_id: "group_name")
        instance.consumer(group_id: "group_name")
      end

      it 'returns an object that responds to "subscribe"' do
        expect(instance.consumer(group_id: "group_name")).to respond_to(:subscribe)
      end

      describe '#stop' do
        let(:consumer) { instance.consumer(group_id: "group_name") }

        it 'calls "stop" on the Kafka consumer' do
          expect(kafka_consumer).to receive(:stop)
          consumer.stop
        end
      end

      describe '#subscribe' do
        let(:consumer) { instance.consumer(group_id: "group_name") }

        it 'calls "subscribe" on a Kafka consumer' do
          expect(kafka_consumer).to receive(:subscribe).with("topic_name", any_args)
          consumer.subscribe("topic_name")
        end

        context 'with a topic prefix configured' do
          before do
            ENV['KAFKA_TOPIC_PREFIX'] = "PREFIX"
          end
          after do
            ENV.delete 'KAFKA_TOPIC_PREFIX'
          end

          it 'calls subscribe on the kafka consumer with the topic name prefixed' do
            expect(kafka_consumer).to receive(:subscribe).with("PREFIXtopic", any_args)
            consumer.subscribe("topic")
          end
        end
      end
    end
  end

  context 'when KAFKA_BROKERS environment variable is not set' do
    before do
      ENV['KAFKA_CA'] = "-----BEGIN CA CERTIFICATE-----\nabcd\n---END---"
      ENV['KAFKA_CERT'] = "-----BEGIN CERTIFICATE-----\\nabcd\\n---END---"
      ENV['KAFKA_PRIVATE_KEY'] = "CERT_KEY"
    end

    it 'raises an error' do
      expect { instance }.to raise_error(/KAFKA_BROKERS not set in the environment/)
    end
  end

  context 'when KAFKA_BROKERS contains at least one ssl broker' do
    before do
      ENV['KAFKA_BROKERS'] = "kafka+ssl://host1:123,host2:234"
    end

    context 'when KAFKA_CA environment variable is not set' do
      before do
        ENV['KAFKA_CERT'] = "-----BEGIN CERTIFICATE-----\\nabcd\\n---END---"
        ENV['KAFKA_PRIVATE_KEY'] = "CERT_KEY"
      end

      it 'raises an error' do
        expect { instance }.to raise_error(/KAFKA_CA not set in the environment/)
      end
    end

    context 'when KAFKA_CERT environment variable is not set' do
      before do
        ENV['KAFKA_CA'] = "-----BEGIN CA CERTIFICATE-----\nabcd\n---END---"
        ENV['KAFKA_PRIVATE_KEY'] = "CERT_KEY"
      end

      it 'raises an error' do
        expect { instance }.to raise_error(/KAFKA_CERT not set in the environment/)
      end
    end

    context 'when KAFKA_PRIVATE_KEY environment variable is not set' do
      before do
        ENV['KAFKA_CA'] = "-----BEGIN CA CERTIFICATE-----\nabcd\n---END---"
        ENV['KAFKA_CERT'] = "-----BEGIN CERTIFICATE-----\\nabcd\\n---END---"
      end

      it 'raises an error' do
        expect { instance }.to raise_error(/KAFKA_PRIVATE_KEY not set in the environment/)
      end
    end
  end
  context 'when KAFKA_BROKERS does not contain an ssl broker' do
    before do
      ENV['KAFKA_BROKERS'] = "kafka://host1:123,host2:234"
    end

    it 'does not require KAFKA_CA, KAFKA_CERT, or KAFKA_PRIVATE_KEY' do
      expect { instance }.to_not raise_error
    end
  end
end
