# frozen_string_literal: true

module AnnotateRb
  class Env
    class << self
      def read(key)
        key = key.to_s unless key.is_a?(String)

        ENV[key]
      end

      def write(key, value)
        key = key.to_s unless key.is_a?(String)

        ENV[key] = value.to_s
      end

      def fetch(key, default_value)
        key = key.to_s unless key.is_a?(String)
        val = read(key)

        if val.nil?
          default_value
        else
          val
        end
      end
    end
  end
end
