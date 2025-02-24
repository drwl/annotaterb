# frozen_string_literal: true

module Annotaterb
  module Commands
    autoload :PrintVersion, "annotaterb/commands/print_version"
    autoload :PrintHelp, "annotaterb/commands/print_help"
    autoload :AnnotateModels, "annotaterb/commands/annotate_models"
    autoload :AnnotateRoutes, "annotaterb/commands/annotate_routes"
  end
end
