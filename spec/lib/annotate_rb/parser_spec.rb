module AnnotateRb # rubocop:disable Metrics/ModuleLength
  RSpec.describe Parser do
    subject(:result) { described_class.parse(args, existing_options) }
    let(:existing_options) { {} }

    describe "commands" do
      describe "models" do
        let(:args) { ["models"] }

        it "sets the command option" do
          expect(result).to include(command: instance_of(Commands::AnnotateModels))
        end
      end

      describe "routes" do
        let(:args) { ["routes"] }

        it "sets the command option" do
          expect(result).to include(command: instance_of(Commands::AnnotateRoutes))
        end
      end

      describe "help" do
        let(:args) { ["help"] }

        it "sets the command option" do
          expect(result).to include(command: instance_of(Commands::PrintHelp))
        end
      end

      describe "version" do
        let(:args) { ["version"] }

        it "sets the command option" do
          expect(result).to include(command: instance_of(Commands::PrintVersion))
        end
      end
    end

    context "when given empty args" do
      let(:args) { [] }

      it "returns an options hash with defaults" do
        expect(result).to be_a(Hash)
        expect(result).to include(target_action: :do_annotations)
      end
    end

    %w[--additional-file-patterns].each do |option|
      describe option do
        let(:args) { [option, paths] }
        let(:paths) { "foo/bar,baz" }

        it "sets array of paths to :additional_file_patterns" do
          expect(result).to include(additional_file_patterns: ["foo/bar", "baz"])
        end
      end
    end

    %w[-d --delete].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets target_action to :remove_annotations" do
          expect(result).to include(target_action: :remove_annotations)
        end
      end
    end

    %w[-p --position].each do |option|
      describe option do
        Parser::ANNOTATION_POSITIONS.each do |position|
          context "when specifying #{position}" do
            let(:args) { [option, position] }

            it "#{position} position is an option" do
              expect(Parser::ANNOTATION_POSITIONS).to include(position)
            end

            it "sets position to be the position" do
              expect(result).to include(position: position)
            end

            it "sets position for the different file types" do
              Parser::FILE_TYPE_POSITIONS.each do |file_type|
                expect(result).to include(file_type.to_sym => position)
              end
            end
          end
        end
      end
    end

    context "when position_in_class is set to top" do
      context "and when position is a different value" do
        let(:other_commands) { %w[--pc top] }
        let(:position_command) { %w[-p bottom] }
        let(:args) { other_commands + position_command }

        it "does not override" do
          expect(result[:position_in_class]).to eq("top")
          expect(result[:position]).to eq("bottom")
        end
      end
    end

    %w[--pc --position-in-class].each do |option|
      describe option do
        Parser::ANNOTATION_POSITIONS.each do |position|
          context "when specifying '#{position}'" do
            let(:args) { [option, position] }

            it "sets the position_in_class to '#{position}'" do
              expect(result).to include(position_in_class: position)
            end
          end
        end
      end
    end

    %w[--pf --position-in-factory].each do |option|
      describe option do
        Parser::ANNOTATION_POSITIONS.each do |position|
          context "when specifying '#{position}'" do
            let(:args) { [option, position] }

            it "sets the position_in_factory to '#{position}'" do
              expect(result).to include(position_in_factory: position)
            end
          end
        end
      end
    end

    %w[--px --position-in-fixture].each do |option|
      describe option do
        Parser::ANNOTATION_POSITIONS.each do |position|
          context "when specifying '#{position}'" do
            let(:args) { [option, position] }

            it "sets the position_in_fixture to '#{position}'" do
              expect(result).to include(position_in_fixture: position)
            end
          end
        end
      end
    end

    %w[--pt --position-in-test].each do |option|
      describe option do
        Parser::ANNOTATION_POSITIONS.each do |position|
          context "when specifying '#{position}'" do
            let(:args) { [option, position] }

            it "sets the position_in_test to '#{position}'" do
              expect(result).to include(position_in_test: position)
            end
          end
        end
      end
    end

    %w[--pr --position-in-routes].each do |option|
      describe option do
        Parser::ANNOTATION_POSITIONS.each do |position|
          context "when specifying '#{position}'" do
            let(:args) { [option, position] }

            it "sets the position_in_routes to '#{position}'" do
              expect(result).to include(position_in_routes: position)
            end
          end
        end
      end
    end

    %w[--ps --position-in-serializer].each do |option|
      describe option do
        Parser::ANNOTATION_POSITIONS.each do |position|
          context "when specifying '#{position}'" do
            let(:args) { [option, position] }

            it "sets the position_in_serializer to '#{position}'" do
              expect(result).to include(position_in_serializer: position)
            end
          end
        end
      end
    end

    %w[--pa --position-in-additional-file-patterns].each do |option|
      describe option do
        Parser::ANNOTATION_POSITIONS.each do |position|
          context "when specifying '#{position}'" do
            let(:args) { [option, position] }

            it "sets the position_in_additional_file_patterns to '#{position}'" do
              expect(result).to include(position_in_additional_file_patterns: position)
            end
          end
        end
      end
    end

    %w[--w --wrapper].each do |option|
      describe option do
        let(:wrapper_text) { "WRAPPER_STR" }
        let(:args) { [option, wrapper_text] }

        it "sets the wrapper value" do
          expect(result).to include(wrapper: wrapper_text)
        end
      end
    end

    %w[--wo --wrapper-open].each do |option|
      describe option do
        let(:wrapper_text) { "WRAPPER_STR" }
        let(:args) { [option, wrapper_text] }

        it "sets the wrapper open value" do
          expect(result).to include(wrapper_open: wrapper_text)
        end
      end
    end

    %w[--wc --wrapper-close].each do |option|
      describe option do
        let(:wrapper_text) { "WRAPPER_STR" }
        let(:args) { [option, wrapper_text] }

        it "sets the wrapper close value" do
          expect(result).to include(wrapper_close: wrapper_text)
        end
      end
    end

    %w[-a --active-admin].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets active_admin to true" do
          expect(result).to include(active_admin: true)
        end
      end
    end

    %w[--show-migration].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets include_version to true" do
          expect(result).to include(include_version: true)
        end
      end
    end

    %w[-k --show-foreign-keys].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets show_foreign_keys to true" do
          expect(result).to include(show_foreign_keys: true)
        end
      end
    end

    %w[--ck --complete-foreign-keys].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets show_foreign_keys and show_complete_foreign_keys to true" do
          expect(result).to include(show_foreign_keys: true, show_complete_foreign_keys: true)
        end
      end
    end

    %w[-i --show-indexes].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets show_indexes to true" do
          expect(result).to include(show_indexes: true)
        end
      end
    end

    %w[-s --simple-indexes].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets simple_indexes to true" do
          expect(result).to include(simple_indexes: true)
        end
      end
    end

    %w[-c --show-check-constraints].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets show_check_constraints to true" do
          expect(result).to include(show_check_constraints: true)
        end
      end
    end

    describe "--model-dir" do
      let(:option) { "--model-dir" }
      let(:set_value) { "some_dir/" }
      let(:args) { [option, set_value] }

      it "sets the model_dir value" do
        expect(result).to include(model_dir: set_value)
      end
    end

    describe "--root-dir" do
      let(:option) { "--root-dir" }
      let(:set_value) { "some_dir/" }
      let(:args) { [option, set_value] }

      it "sets the root_dir value" do
        expect(result).to include(root_dir: set_value)
      end
    end

    describe "--ignore-model-subdirects" do
      let(:args) { ["--ignore-model-subdirects"] }

      it "sets ignore_model_sub_dir to true" do
        expect(result).to include(ignore_model_sub_dir: true)
      end
    end

    describe "--sort" do
      let(:args) { ["--sort"] }

      it "sets sort to true" do
        expect(result).to include(sort: true)
      end
    end

    describe "--classified-sort" do
      let(:args) { ["--classified-sort"] }

      it "sets classified_sort to true" do
        expect(result).to include(classified_sort: true)
      end
    end

    %w[-R --require].each do |option|
      describe option do
        let(:option) { "require" }
        let(:set_value) { "another_dir" }

        let(:args) { [option, set_value] }

        it "sets the 'require' value" do
          expect(result).to include(require: set_value)
        end

        context "when 'require' is already set" do
          let(:preset_require_value) { "some_dir/" }
          let(:existing_options) { {require: preset_require_value} }

          it "appends the path to 'require'" do
            expect(result).to include(require: "#{preset_require_value},#{set_value}")
          end
        end
      end
    end

    describe "Parser::EXCLUSION_LIST" do
      it "has 'tests'" do
        expect(Parser::EXCLUSION_LIST).to include("tests")
      end

      it "has 'fixtures'" do
        expect(Parser::EXCLUSION_LIST).to include("fixtures")
      end

      it "has 'factories'" do
        expect(Parser::EXCLUSION_LIST).to include("factories")
      end

      it "has 'serializers'" do
        expect(Parser::EXCLUSION_LIST).to include("serializers")
      end
    end

    %w[-e --exclude].each do |option|
      describe option do
        let(:args) { [option] }

        it "sets the values for 'tests', 'fixtures', 'factories', and 'serializers' to true" do
          expect(result).to include(exclude_tests: true)
          expect(result).to include(exclude_fixtures: true)
          expect(result).to include(exclude_factories: true)
          expect(result).to include(exclude_serializers: true)
        end

        context "when a type is passed in" do
          let(:exclusions) { "tests" }
          let(:args) { [option, exclusions] }

          it "only sets 'exclude_tests' to true" do
            expect(result).to include(exclude_tests: true)
            expect(result).not_to include(exclude_fixtures: true)
            expect(result).not_to include(exclude_factories: true)
            expect(result).not_to include(exclude_serializers: true)
          end
        end

        context "when two types are passed in" do
          let(:exclusions) { "tests,fixtures" }
          let(:args) { [option, exclusions] }

          it "sets 'exclude_tests' and 'exclude_fixtures' to true" do
            expect(result).to include(exclude_tests: true)
            expect(result).to include(exclude_fixtures: true)
            expect(result).not_to include(exclude_factories: false)
            expect(result).not_to include(exclude_serializers: false)
          end
        end
      end
    end

    %w[-f --format].each do |option|
      describe option do
        Parser::FORMAT_TYPES.each do |format_type|
          context "when passing in format type '#{format_type}'" do
            let(:format_key) { "format_#{format_type}".to_sym }
            let(:args) { [option, format_type] }

            it "sets key for the format type to true" do
              expect(result).to include(format_key => true)
            end
          end
        end
      end
    end

    describe "--force" do
      let(:option) { "--force" }
      let(:args) { [option] }

      it "sets force to true" do
        expect(result).to include(force: true)
      end
    end

    describe "--frozen" do
      let(:option) { "--frozen" }
      let(:args) { [option] }

      it "sets frozen to true" do
        expect(result).to include(frozen: true)
      end
    end

    describe "--timestamp" do
      let(:option) { "--timestamp" }
      let(:args) { [option] }

      it "sets timestamp to true" do
        expect(result).to include(timestamp: true)
      end
    end

    describe "--trace" do
      let(:option) { "--trace" }
      let(:args) { [option] }

      it "sets trace to true" do
        expect(result).to include(trace: true)
      end
    end

    %w[-I --ignore-columns].each do |option|
      describe option do
        let(:regex) { "^(id|updated_at|created_at)" }
        let(:args) { [option, regex] }

        it "sets the ignore_columns value" do
          expect(result).to include(ignore_columns: regex)
        end
      end
    end

    describe "--ignore-routes" do
      let(:option) { "--ignore-routes" }
      let(:regex) { "(mobile|resque|pghero)" }
      let(:args) { [option, regex] }

      it "sets the ignore_routes value" do
        expect(result).to include(ignore_routes: regex)
      end
    end

    describe "--hide-limit-column-types" do
      let(:option) { "--hide-limit-column-types" }
      let(:values) { "integer,boolean,text" }
      let(:args) { [option, values] }

      it "sets the hide_limit_column_types value" do
        expect(result).to include(hide_limit_column_types: values)
      end
    end

    describe "--hide-default-column-types" do
      let(:option) { "--hide-default-column-types" }
      let(:values) { "json,jsonb,hstore" }
      let(:args) { [option, values] }

      it "sets the hide_default_column_types value" do
        expect(result).to include(hide_default_column_types: values)
      end
    end

    describe "--ignore-unknown-models" do
      let(:option) { "--ignore-unknown-models" }
      let(:args) { [option] }

      it "sets ignore_unknown_models to true" do
        expect(result).to include(ignore_unknown_models: true)
      end
    end

    describe "--with-comment" do
      let(:option) { "--with-comment" }
      let(:args) { [option] }

      it "sets with_comment to true" do
        expect(result).to include(with_comment: true)
      end
    end

    describe "--without-comment" do
      let(:option) { "--without-comment" }
      let(:args) { [option] }

      it "sets with_comment to false" do
        expect(result).to include(with_comment: false)
      end
    end

    describe "--with-table-comments" do
      let(:option) { "--with-table-comments" }
      let(:args) { [option] }

      it "sets with_table_comments to true" do
        expect(result).to include(with_table_comments: true)
      end
    end

    describe "--without-table-comments" do
      let(:option) { "--without-table-comments" }
      let(:args) { [option] }

      it "sets with_table_comments to false" do
        expect(result).to include(with_table_comments: false)
      end
    end

    describe "--with-column-comments" do
      let(:option) { "--with-column-comments" }
      let(:args) { [option] }

      it "sets with_column_comments to true" do
        expect(result).to include(with_column_comments: true)
      end
    end

    describe "--without-column-comments" do
      let(:option) { "--without-column-comments" }
      let(:args) { [option] }

      it "sets with_column_comments to false" do
        expect(result).to include(with_column_comments: false)
      end
    end

    describe "--position-of-column-comments" do
      let(:option) { "--position-of-column-comments" }
      let(:values) { "rightmost_column"}
      let(:args) { [option, values] }

      it "sets with_column_comments to true" do
        expect(result).to include(position_of_column_comments: :rightmost_column)
      end
    end
  end
end
