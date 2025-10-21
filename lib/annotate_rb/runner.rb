# frozen_string_literal: true

module AnnotateRb
  class Runner
    class << self
      attr_reader :runner

      def run(args)
        self.runner = new

        runner.run(args)

        self.runner = nil
      end

      def running?
        !!runner
      end

      private

      attr_writer :runner
    end

    def run(args)
      parser = Parser.new(args, {})
      parsed_options = parser.parse
      remaining_args = parser.remaining_args

      AnnotateRb::RakeBootstrapper.call

      options = ConfigLoader.load_config.merge(parsed_options)
      @options = Options.from(ConfigLoader.load_config.merge(parsed_options), { working_args: remaining_args })

      raise "Didn't specify a command" unless @options[:command]

      @options[:command].call(@options)
    end
  end
end
