# frozen_string_literal: true

module AnnotateRb
  class Runner
    class << self
      def run(args)
        new.run(args)
      end
    end

    def initialize
    end

    def run(args)
      _original_args = args.dup

      config_file_options = ConfigLoader.load_config
      parsed_options = Parser.parse(args)

      options = config_file_options.merge(parsed_options)

      @options = Options.from(options, {})
      AnnotateRb::RakeBootstrapper.call(@options)

      if @options[:command]
        @options[:command].call(@options)
      else
        # TODO
        raise "Didn't specify a command"
      end
    end
  end
end
