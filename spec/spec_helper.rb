require "bundler/setup"
require "rake"
require "active_support"
require "active_support/core_ext/string"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/class/subclasses"
require "active_support/core_ext/string/inflections"
require "byebug"
require "bigdecimal"
require "tmpdir"

require "annotate_rb"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.include(SpecHelper::Aruba, type: :aruba)

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random

  config.include_context "isolated environment", :isolated_environment
end
