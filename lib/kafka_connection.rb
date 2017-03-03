require "kafka_connection/version"
require "kafka_connection/connection"
require "kafka_connection/producer"
require "kafka_connection/consumer"
require "kafka_connection/pool"

module KafkaConnection
  def self.new(app_name:, env_name:, pool_idx: 0)
    Connection.new(app_name: app_name, env_name: env_name, pool_idx: pool_idx)
  end

  def self.pool(size:, app_name:, env_name:, timeout: 5)
    Pool.new(size: size, app_name: app_name, env_name: env_name, timeout: timeout)
  end
end
