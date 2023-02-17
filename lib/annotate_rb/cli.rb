# frozen_string_literal: true

module AnnotateRb
  class CLI
    def initialize
      @options = {}
    end

    STATUS_SUCCESS = 0
    STATUS_ERROR = 1

    HELP_MAPPING = %w(-h -? --help).to_set
    VERSION_MAPPING = %w(-v --version).to_set

    def run(args = ARGV)
      _original_argv = ARGV.dup

      case args.first
      when HELP_MAPPING, "help", nil
        Commands::Help.run
        STATUS_SUCCESS
      when VERSION_MAPPING
        Commands::Version.run
        STATUS_SUCCESS
      else
        Runner.run(args)
      end
    end
  end
end
