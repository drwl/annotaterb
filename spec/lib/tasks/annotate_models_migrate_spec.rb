RSpec.describe 'ActiveRecord migration rake task hooks' do
  before do
    Rake.application = Rake::Application.new

    # Stub migration tasks
    %w(db:migrate db:migrate:up db:migrate:down db:migrate:reset db:rollback).each do |task|
      Rake::Task.define_task(task)
    end

    Rake::Task.define_task('db:migrate:redo') do
      Rake::Task['db:rollback'].invoke
      Rake::Task['db:migrate'].invoke
    end

    # Rake::Task.define_task('set_annotation_options')
    Rake.load_rakefile('tasks/annotate_models_migrate.rake')

    Rake.application.instance_variable_set(:@top_level_tasks, [subject])
  end

  describe 'db:migrate' do
    it 'should update annotations' do
      # TODO: Add expectation
      # expect(AnnotateRb::Migration).to receive(:update_annotations)
      Rake.application.top_level
    end
  end

  describe 'db:migrate:up' do
    it 'should update annotations' do
      # TODO: Add expectation
      # expect(AnnotateRb::Migration).to receive(:update_annotations)
      Rake.application.top_level
    end
  end

  describe 'db:migrate:down' do
    it 'should update annotations' do
      # TODO: Add expectation
      # expect(AnnotateRb::Migration).to receive(:update_annotations)
      Rake.application.top_level
    end
  end

  describe 'db:migrate:reset' do
    it 'should update annotations' do
      # TODO: Add expectation
      # expect(AnnotateRb::Migration).to receive(:update_annotations)
      Rake.application.top_level
    end
  end

  describe 'db:rollback' do
    it 'should update annotations' do
      # TODO: Add expectation
      # expect(AnnotateRb::Migration).to receive(:update_annotations)
      Rake.application.top_level
    end
  end

  describe 'db:migrate:redo' do
    it 'should update annotations after all migration tasks' do
      # TODO: Add expectation
      # expect(AnnotateRb::Migration).to receive(:update_annotations)

      # Confirm that update_annotations isn't called when the original redo task finishes
      Rake::Task[subject].enhance do
        # expect(AnnotateRb::Migration).not_to have_received(:update_annotations)
      end

      Rake.application.top_level

      # Hooked 3 times by db:rollback, db:migrate, and db:migrate:redo tasks
      # expect(AnnotateRb::Migration).to have_received(:update_annotations).exactly(3).times
    end
  end
end
