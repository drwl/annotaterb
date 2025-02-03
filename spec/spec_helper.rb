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
  config.filter_run focus: true
  config.include(SpecHelper::Aruba, type: :aruba)

  config.before(:example, type: :aruba) do
    copy_dummy_app_into_aruba_working_directory

    # Unset the bundler context from running annotaterb integration specs.
    #   This way, when `run_command("bundle exec annotaterb")` runs, it runs as if it's within the context of dummyapp.
    unset_bundler_env_vars
  end

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
