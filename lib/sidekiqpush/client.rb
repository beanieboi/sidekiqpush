module SidekiqPush
  class Client
    def self.enqueue(payload)
      new(payload).enqueue
    end

    def initialize(payload, redis=Redis.new)
      @payload = payload
      @redis = redis
    end

    def enqueue
      enqueue_now!
      normalized_payload['jid'.freeze]
    end

    private

    def normalized_payload
      @normalized_payload ||= Normalizer.new(@payload).normalize
    end

    def enqueue_now!
      normalized_payload['enqueued_at'.freeze] = Time.now.to_f
      redis.sadd('queues'.freeze, queue)
      redis.lpush("queue:#{queue}", push)
    end

    def queue
      normalized_payload['queue'.freeze]
    end

    def push
      JSON.generate(normalized_payload)
    end

    attr_reader :redis
  end
end
