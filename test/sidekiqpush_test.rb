require 'test_helper'

class SidekiqpushTest < Minitest::Test
  class Fakeredis
    attr_reader :set, :list

    def initialize
      @set = {}
      @list = {}
    end

    def sadd(set_name, set_value)
      @set[set_name] = set_value
    end

    def lpush(list_name, list_item)
      @list[list_name] = list_item
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Sidekiqpush::VERSION
  end

  def test_it_enqueues_payload
    redis = Fakeredis.new
    SidekiqPush::Client.new(payload, redis).enqueue

    assert_equal "test_queue", redis.set["queues"]

    hash = JSON.parse(redis.list["queue:test_queue"])
    assert_equal false, hash["retry"]
    assert_equal "test_queue", hash["queue"]
    assert_equal "TestClass", hash["class"]
    assert_equal [1, "my_params"], hash["args"]
    refute_nil hash["jid"]
    refute_nil hash["created_at"]
    refute_nil hash["enqueued_at"]
  end

  private

  def payload
    {
      'retry' => false,
      'queue' => "test_queue",
      'class' => 'TestClass',
      'args' => [1, "my_params"]
    }
  end
end
