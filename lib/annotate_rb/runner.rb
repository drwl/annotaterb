# frozen_string_literal: true

module AnnotateRb
  class Runner
    MODEL_MAPPING = %w(models).to_set
    ROUTE_MAPPING = %w(routes).to_set

    class << self
      def run(args)
        new.run(args)
      end
    end

    def initialize

    end

    def run(args)
      # From args, let's parse the args
      # Decide what to run from there
      # Want to only run 1 command at a time here, either annotate models or routes

      _original_args = args.dup

      command = args.shift
      @options = parse_options(args)

      case command
      when MODEL_MAPPING
        puts "Model mapping"
        @options
      when ROUTE_MAPPING
        puts "Route mapping"
      else
        puts "Invalid arguments, got: #{args}"
        return CLI::STATUS_ERROR
      end
    end

    def parse_options(args)
      Parser.parse(args)
    end
  end
end
