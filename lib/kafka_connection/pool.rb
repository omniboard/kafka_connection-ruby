require 'connection_pool'

module KafkaConnection
  class Pool
    extend Forwardable

    def initialize(size:, app_name:, env_name:, timeout: 5)
      @pool_idx = 0
      @pool = ConnectionPool.new(size: size, timeout: timeout) {
        @pool_idx += 1
        Connection.new(app_name: app_name, env_name: env_name, pool_idx: @pool_idx)
      }
    end

    def_delegator :@pool, :with
  end
end
