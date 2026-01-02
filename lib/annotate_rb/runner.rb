# frozen_string_literal: true

module AnnotateRb
  class Runner
    class << self
      attr_reader :runner

      def run_after_migration
        config_file_options = ConfigLoader.load_config
        options = Options.from(config_file_options)

        commands = ["models", *(options[:auto_annotate_routes_after_migrate] ? ["routes"] : [])]
        commands.each { |cmd| run([cmd], config_file_options: config_file_options) }
      end

      def run(args, config_file_options: nil)
        self.runner = new

        runner.run(args, config_file_options: config_file_options)

        self.runner = nil
      end

      def running?
        !!runner
      end

      private

      attr_writer :runner
    end

    def run(args, config_file_options: nil)
      config_file_options ||= ConfigLoader.load_config
      parser = Parser.new(args, {})

      parsed_options = parser.parse
      remaining_args = parser.remaining_args

      options = config_file_options.merge(parsed_options)

      @options = Options.from(options, {working_args: remaining_args})
      AnnotateRb::RakeBootstrapper.call

      if @options[:command]
        @options[:command].call(@options)
      else
        # TODO
        raise "Didn't specify a command"
      end
    end
  end
end
