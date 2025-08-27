RSpec.describe "ActiveRecord migration rake task hooks" do
  context "single database" do
    before do
      Rake.application = Rake::Application.new

      # Stub migration tasks
      %w[db:migrate db:migrate:up db:migrate:down db:migrate:reset db:rollback].each do |task|
        Rake::Task.define_task(task)
      end

      Rake::Task.define_task("db:migrate:redo") do
        Rake::Task["db:rollback"].invoke
        Rake::Task["db:migrate"].invoke
      end

      Rake.load_rakefile("annotate_rb/tasks/annotate_models_migrate.rake")

      Rake.application.instance_variable_set(:@top_level_tasks, [subject])
    end

    describe "db:migrate" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end

    describe "db:migrate:up" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end

    describe "db:migrate:down" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end

    describe "db:migrate:reset" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end

    describe "db:rollback" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end

    describe "db:migrate:redo" do
      it "should annotate model files after all migration tasks" do
        # Hooked 3 times by db:rollback, db:migrate, and db:migrate:redo tasks
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models")).exactly(3).times

        Rake.application.top_level
      end
    end
  end

  context "multiple databases" do
    def stub_rails(version, database_names)
      stub_const("Rails::Application", Class.new)
      allow(Rails).to receive(:version).and_return(version)

      stub_const("ActiveRecord::Tasks::DatabaseTasks", Module.new)

      allow(ActiveRecord::Tasks::DatabaseTasks).to receive(:setup_initial_database_yaml) do
        database_names.index_with do
          {}
        end
      end

      allow(ActiveRecord::Tasks::DatabaseTasks).to receive(:for_each) do |databases, &block|
        databases.each { |name, config| block.call(name) }
      end
    end

    before do
      stub_rails "6.0.0", ["primary"]

      Rake.application = Rake::Application.new

      %w[db:migrate db:migrate:up db:migrate:down db:rollback].each do |task|
        Rake::Task.define_task("#{task}:primary")
      end

      Rake.load_rakefile("annotate_rb/tasks/annotate_models_migrate.rake")

      Rake.application.instance_variable_set(:@top_level_tasks, [subject])
    end

    describe "db:migrate:primary" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end

    describe "db:migrate:up:primary" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end

    describe "db:migrate:down:primary" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end

    describe "db:rollback:primary" do
      it "should annotate model files" do
        expect(AnnotateRb::Runner).to receive(:run).with(a_collection_including("models"))
        Rake.application.top_level
      end
    end
  end
end
