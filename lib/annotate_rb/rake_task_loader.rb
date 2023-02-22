# frozen_string_literal: true

module AnnotateRb
  class RakeTaskLoader
    class << self
      # Can be used by consumers, per README:
      #
      # To automatically annotate every time you run `db:migrate`,
      # either run `rails g annotate:install`
      # or add `Annotate.load_tasks` to your `Rakefile`.
      def call(options)
        return if options.get_state(:tasks_loaded)

        # Loads rake tasks, not sure why yet
        Dir[File.join(File.dirname(__FILE__), '..', 'tasks', '**/*.rake')].each do |rake|
          load rake
        end

        options.set_state(:tasks_loaded, true)
      end
    end
  end
end
