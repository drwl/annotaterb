# frozen_string_literal: true

module Annotaterb
  module Commands
    class PrintVersion
      def call(_options)
        puts "Annotaterb v#{Core.version}"
      end
    end
  end
end
