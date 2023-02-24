# frozen_string_literal: true

require 'pry-byebug'

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

      parsed_options = Parser.parse(args)

      @options = Options.from(parsed_options, {})
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
