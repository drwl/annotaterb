# frozen_string_literal: true

require "active_record"
require "active_support"

# Helper.fallback depends on this being required because it adds #present? to nil
require "active_support/core_ext/object/blank"
require "active_support/core_ext/class/subclasses"
require "active_support/core_ext/string/inflections"

require "rake"

require_relative "annotaterb/helper"
require_relative "annotaterb/core"
require_relative "annotaterb/commands"
require_relative "annotaterb/parser"
require_relative "annotaterb/runner"
require_relative "annotaterb/route_annotator"
require_relative "annotaterb/model_annotator"
require_relative "annotaterb/options"
require_relative "annotaterb/eager_loader"
require_relative "annotaterb/rake_bootstrapper"
require_relative "annotaterb/config_finder"
require_relative "annotaterb/config_loader"
require_relative "annotaterb/config_generator"

module Annotaterb
end
