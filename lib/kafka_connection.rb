require "kafka_connection/version"
require "kafka_connection/connection"
require "kafka_connection/producer"
require "kafka_connection/consumer"

module KafkaConnection
  def self.new(app_name:, env_name:, pool_idx:)
    Connection.new(app_name: app_name, env_name: env_name, pool_idx: pool_idx)
  end
end
