require "securerandom"

module SidekiqPush
  class Normalizer
    def initialize(payload)
      @payload = payload
    end

    def normalize
      set_defaults

      @payload['class'.freeze] = @payload['class'.freeze].to_s
      @payload['queue'.freeze] = @payload['queue'.freeze].to_s
      @payload['jid'.freeze] ||= SecureRandom.hex(12)
      @payload['created_at'.freeze] ||= Time.now.to_f
      @payload
    end

    private

    def check_payload!
      fail(ArgumentError, 'Job must be a Hash') unless @payload.is_a?(Hash)

      unless @payload.key?('class'.freeze)
        fail(ArgumentError, "Job must needs 'class' key")
      end

      unless @payload.key?('args'.freeze)
        fail(ArgumentError, "Job must needs 'args' key")
      end

      unless @payload['args'.freeze].is_a?(Array)
        fail(ArgumentError, 'Job args must be an Array')
      end

      unless @payload['class'.freeze].is_a?(Class) || @payload['class'.freeze].is_a?(String)
        fail(ArgumentError, 'Job class must be either a Class or String representation of the class name')
      end
    end

    def set_defaults
      @payload['retry'.freeze] = true if @payload['retry'.freeze].nil?
      @payload['queue'.freeze] = 'default' if @payload['queue'.freeze].nil?
    end
  end
end
