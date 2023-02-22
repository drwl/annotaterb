# frozen_string_literal: true

# TODO: Check if these requires are still needed. Copied from old Annotate code.
# begin
#   # ActiveSupport 3.x...
#   require 'active_support/hash_with_indifferent_access'
#   require 'active_support/core_ext/object/blank'
# rescue StandardError
#   # ActiveSupport 2.x...
#   require 'active_support/core_ext/hash/indifferent_access'
#   require 'active_support/core_ext/blank'
# end

require_relative 'annotate_rb/core'
require_relative 'annotate_rb/parser'
require_relative 'annotate_rb/runner'
require_relative 'annotate_rb/commands'
require_relative 'annotate_rb/route_annotator'
require_relative 'annotate_rb/model_annotator'
require_relative 'annotate_rb/env'
require_relative 'annotate_rb/options'

module AnnotateRb

end
