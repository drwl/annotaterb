# This rake task was added by annotaterb gem.

# Can set `ANNOTATERB_SKIP_ON_DB_TASKS` to be anything to skip this
if Rails.env.development? && ENV["ANNOTATERB_SKIP_ON_DB_TASKS"].nil?
  require "annotaterb"

  Annotaterb::Core.load_rake_tasks
end
