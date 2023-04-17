# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.
if Rails.env.development?
  require 'annotate_rb'
  task :set_annotation_options do
    # You can override any of these by setting an environment variable of the
    # same name.

    # TODO: Port to using new AnnotateRb::Options
    # AnnotateRb::OldAnnotate.set_defaults(
    #   ...
    # )
  end

  AnnotateRb::OldAnnotate.load_tasks
end
