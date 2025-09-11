# Use this shared context to run specs in a simulated multi-database environment.
#
# This sets the `MULTI_DB_TEST` environment variable, which is used by the
# dummy app's `database.yml` to include the secondary database configuration.
RSpec.shared_context "when in a multi database environment" do
  before do
    set_environment_variable("MULTI_DB_TEST", "true")
  end
end
