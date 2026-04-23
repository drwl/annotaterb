# These tasks are added to the project if you install annotate as a Rails plugin.
# (They are not used to build annotate itself.)

# Append annotations to Rake tasks for ActiveRecord, so annotate automatically gets
# run after doing db:migrate.

# Migration tasks are tasks that we'll "hook" into
migration_tasks = %w[db:migrate db:migrate:up db:migrate:down db:migrate:reset db:migrate:redo db:rollback]

# Support for data_migrate gem (https://github.com/ilyakatz/data-migrate)
migration_tasks_with_data = migration_tasks.map { |task| "#{task}:with_data" }
migration_tasks += migration_tasks_with_data

if defined?(Rails::Application) && Rails.version.split(".").first.to_i >= 6
  require "active_record"

  databases = ActiveRecord::Tasks::DatabaseTasks.setup_initial_database_yaml

  # If there's multiple databases, this appends database specific rake tasks to `migration_tasks`
  ActiveRecord::Tasks::DatabaseTasks.for_each(databases) do |database_name|
    migration_tasks.concat(%w[db:migrate db:migrate:up db:migrate:down db:rollback].map { |task| "#{task}:#{database_name}" })
  end
end

config = ::AnnotateRb::ConfigLoader.load_config

migration_tasks.each do |task|
  next unless Rake::Task.task_defined?(task)
  next if config[:skip_on_db_migrate]

  Rake::Task[task].enhance do |current_task| # This block is ran after `task` completes
    # Prefer the top-level task (the one invoked from the CLI, e.g. "db:migrate") so that
    # when sub-tasks chain (e.g. db:migrate:redo invokes db:rollback then db:migrate), we
    # defer the annotation run to after everything completes. Fall back to the currently
    # enhanced task when there is no top-level task (e.g. when the task is invoked
    # programmatically from application code rather than from the Rake CLI).
    task_name = Rake.application.top_level_tasks.last || current_task.name

    Rake::Task[task_name].enhance do
      ::AnnotateRb::Runner.run_after_migration
    end
  end
end
