# Use this shared context to run specs in a simulated single-database environment.
#
# This sets the `SINGLE_DB_TEST` environment variable, which is used by the
# dummy app's `database.yml` to exclude the secondary database.
RSpec.shared_context "when in a single database environment" do
  before do
    set_environment_variable("SINGLE_DB_TEST", "true")
  end
end
