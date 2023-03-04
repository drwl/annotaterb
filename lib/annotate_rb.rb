# frozen_string_literal: true

require 'active_record'
require 'active_support'

# Helper.fallback depends on this being required because it adds #present? to nil
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/subclasses'
require 'active_support/core_ext/string/inflections'

require 'rake'

require 'annotate_rb/active_record_patch'

require_relative 'annotate_rb/core'
require_relative 'annotate_rb/commands'
require_relative 'annotate_rb/parser'
require_relative 'annotate_rb/runner'
require_relative 'annotate_rb/route_annotator'
require_relative 'annotate_rb/model_annotator'
require_relative 'annotate_rb/env'
require_relative 'annotate_rb/options'
require_relative 'annotate_rb/eager_loader'
require_relative 'annotate_rb/rake_bootstrapper'

module AnnotateRb

end
