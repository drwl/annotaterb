# frozen_string_literal: true

RSpec.describe Annotaterb::ModelAnnotator::RelatedFilesListBuilder do
  describe "#build" do
    subject { described_class.new(*args).build }

    let(:args) { [file, model_name, table_name, options] }
    let(:file) { "app/models/test_default.rb" }
    let(:model_name) { "test_default" }
    let(:table_name) { "test_defaults" }
    let(:options) { Annotaterb::Options.new({}) }
    let(:include_nothing_options) do
      {
        exclude_tests: true,
        exclude_fixtures: true,
        exclude_factories: true,
        exclude_serializers: true,
        exclude_scaffolds: true,
        exclude_controllers: true,
        exclude_helpers: true,
        active_admin: false,
        additional_file_patterns: [],
        root_dir: [""]
      }
    end

    context "when not adding any related files with an empty project", :isolated_environment do
      let(:options) do
        Annotaterb::Options.new(**include_nothing_options)
      end

      it { is_expected.to be_empty }
    end

    context "when not adding any related files with existing files", :isolated_environment do
      let(:options) do
        Annotaterb::Options.new(**include_nothing_options)
      end

      let(:model_name) { "test_default" }

      before do
        # Add test file
        FileUtils.mkdir_p("spec/models")
        FileUtils.touch("spec/models/test_default_spec.rb")

        # Add test fixtures
        FileUtils.mkdir_p("spec/fixtures")
        FileUtils.touch("test_defaults.yml")

        # Add factories
        FileUtils.mkdir_p("spec/factories")
        FileUtils.touch("spec/factories/test_default_factory.rb")

        # Add serializers
        FileUtils.mkdir_p("spec/serializers")
        FileUtils.touch("spec/serializers/test_default_serializer_spec.rb")

        # Add scaffolds
        FileUtils.mkdir_p("spec/requests")
        FileUtils.touch("spec/requests/test_defaults_spec.rb")

        # Add controllers
        FileUtils.mkdir_p("app/controllers")
        FileUtils.touch("app/controllers/test_defaults_controller.rb")

        # Add helpers
        FileUtils.mkdir_p("app/helpers")
        FileUtils.touch("app/helpers/test_defaults_helper.rb")

        # Add active admin
        FileUtils.mkdir_p("app/admin")
        FileUtils.touch("app/admin/test_default.rb")
      end

      it { is_expected.to be_empty }
    end

    context "when including model tests", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_tests: exclude_tests_option})) }
      let(:exclude_tests_option) { false }

      let(:model_name) { "test_default" }
      let(:test_directory) { "spec/models" }
      let(:test_file_name) { "test_default_spec.rb" }
      let(:relative_file_path) { File.join(test_directory, test_file_name) }
      let(:position_key) { :position_in_test }

      before do
        FileUtils.mkdir_p(test_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end

      context "when exclude_tests is an empty Array" do
        let(:exclude_tests_option) { [] }

        it "returns the test file and the position key" do
          expect(subject).to eq([[relative_file_path, position_key]])
        end
      end

      context "when exclude_tests includes :model" do
        let(:exclude_tests_option) { [:model] }

        it { is_expected.to be_empty }
      end

      context "when exclude_tests includes a non-:model option" do
        let(:exclude_tests_option) { [:controller] }

        it "returns the test file and the position key" do
          expect(subject).to eq([[relative_file_path, position_key]])
        end
      end
    end

    context "when including fixtures", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_fixtures: false})) }

      let(:model_name) { "test_default" }
      let(:fixture_directory) { "spec/fixtures" }
      let(:fixture_file_name) { "test_defaults.yml" }
      let(:relative_file_path) { File.join(fixture_directory, fixture_file_name) }
      let(:position_key) { :position_in_fixture }

      before do
        FileUtils.mkdir_p(fixture_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end
    end

    context "when including factories", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_factories: false})) }

      let(:model_name) { "test_default" }
      let(:factory_directory) { "spec/factories" }
      let(:factory_file_name) { "test_default_factory.rb" }
      let(:relative_file_path) { File.join(factory_directory, factory_file_name) }
      let(:position_key) { :position_in_factory }

      before do
        FileUtils.mkdir_p(factory_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end
    end

    context "when including serializers", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_serializers: false})) }

      let(:model_name) { "test_default" }

      let(:serializer_spec_directory) { "spec/serializers" }
      let(:serializer_test_file) do
        File.join(serializer_spec_directory, "test_default_serializer_spec.rb")
      end

      let(:serializer_directory) { "app/serializers" }
      let(:serializer_file) do
        File.join(serializer_directory, "test_default_serializer.rb")
      end

      let(:position_key) { :position_in_serializer }

      before do
        FileUtils.mkdir_p(serializer_spec_directory)
        FileUtils.touch(serializer_test_file)

        FileUtils.mkdir_p(serializer_directory)
        FileUtils.touch(serializer_file)
      end

      it "returns the test file and the position key" do
        expect(subject).to match_array([
          [serializer_test_file, position_key],
          [serializer_file, position_key]
        ])
      end

      context "when exclude_tests includes :serializer" do
        let(:options) do
          Annotaterb::Options.new(**include_nothing_options.merge(
            {
              exclude_serializers: false,
              exclude_tests: [:serializer]
            }
          ))
        end

        it "returns only the serializer file" do
          expect(subject).to match_array([
            [serializer_file, position_key]
          ])
        end
      end

      context "when exclude_tests does not include :serializer" do
        let(:options) do
          Annotaterb::Options.new(**include_nothing_options.merge(
            {
              exclude_serializers: false,
              exclude_tests: []
            }
          ))
        end

        it "returns both the serializer and serializer test" do
          expect(subject).to match_array([
            [serializer_test_file, position_key],
            [serializer_file, position_key]
          ])
        end
      end
    end

    context "when including scaffolds (request specs)", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_scaffolds: false})) }

      let(:model_name) { "test_default" }
      let(:scaffolded_requests_directory) { "spec/requests" }
      let(:scaffolded_request_spec_file_name) { "test_defaults_spec.rb" }
      let(:relative_file_path) { File.join(scaffolded_requests_directory, scaffolded_request_spec_file_name) }
      let(:position_key) { :position_in_scaffold }

      before do
        FileUtils.mkdir_p(scaffolded_requests_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end

      context "when exclude_tests includes :request" do
        let(:options) do
          Annotaterb::Options.new(**include_nothing_options.merge(
            {
              exclude_scaffolds: false,
              exclude_tests: [:request]
            }
          ))
        end

        it { is_expected.to be_empty }
      end

      context "when exclude_tests does not include :request" do
        let(:options) do
          Annotaterb::Options.new(**include_nothing_options.merge(
            {
              exclude_scaffolds: false,
              exclude_tests: []
            }
          ))
        end

        it "returns the test file and the position key" do
          expect(subject).to eq([[relative_file_path, position_key]])
        end
      end
    end

    context "when including scaffolds (routing specs)", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_scaffolds: false})) }

      let(:model_name) { "test_default" }
      let(:scaffolded_requests_directory) { "spec/routing" }
      let(:scaffolded_request_spec_file_name) { "test_defaults_routing_spec.rb" }
      let(:relative_file_path) { File.join(scaffolded_requests_directory, scaffolded_request_spec_file_name) }
      let(:position_key) { :position_in_scaffold }

      before do
        FileUtils.mkdir_p(scaffolded_requests_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end

      context "when exclude_tests includes :routing" do
        let(:options) do
          Annotaterb::Options.new(**include_nothing_options.merge(
            {
              exclude_scaffolds: false,
              exclude_tests: [:routing]
            }
          ))
        end

        it { is_expected.to be_empty }
      end

      context "when exclude_tests does not include :routing" do
        let(:options) do
          Annotaterb::Options.new(**include_nothing_options.merge(
            {
              exclude_scaffolds: false,
              exclude_tests: []
            }
          ))
        end

        it "returns the test file and the position key" do
          expect(subject).to eq([[relative_file_path, position_key]])
        end
      end
    end

    context "when including scaffolds (controller test)", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_scaffolds: false})) }

      let(:model_name) { "test_default" }
      let(:scaffolded_requests_directory) { "test/controllers" }
      let(:scaffolded_request_spec_file_name) { "test_defaults_controller_test.rb" }
      let(:relative_file_path) { File.join(scaffolded_requests_directory, scaffolded_request_spec_file_name) }
      let(:position_key) { :position_in_scaffold }

      before do
        FileUtils.mkdir_p(scaffolded_requests_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end

      context "when exclude_tests includes :controller" do
        let(:options) do
          Annotaterb::Options.new(**include_nothing_options.merge(
            {
              exclude_scaffolds: false,
              exclude_tests: [:controller]
            }
          ))
        end

        it { is_expected.to be_empty }
      end

      context "when exclude_tests does not include :controller" do
        let(:options) do
          Annotaterb::Options.new(**include_nothing_options.merge(
            {
              exclude_scaffolds: false,
              exclude_tests: []
            }
          ))
        end

        it "returns the test file and the position key" do
          expect(subject).to eq([[relative_file_path, position_key]])
        end
      end
    end

    context "when including controllers", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_controllers: false})) }

      let(:model_name) { "test_default" }
      let(:controllers_directory) { "app/controllers" }
      let(:controller_file_name) { "test_defaults_controller.rb" }
      let(:relative_file_path) { File.join(controllers_directory, controller_file_name) }
      let(:position_key) { :position_in_controller }

      before do
        FileUtils.mkdir_p(controllers_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end
    end

    context "when including helpers", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({exclude_helpers: false})) }

      let(:model_name) { "test_default" }
      let(:helpers_directory) { "app/helpers" }
      let(:helper_file_name) { "test_defaults_helper.rb" }
      let(:relative_file_path) { File.join(helpers_directory, helper_file_name) }
      let(:position_key) { :position_in_helper }

      before do
        FileUtils.mkdir_p(helpers_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end
    end

    context "when including active admin models", :isolated_environment do
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({active_admin: true})) }

      let(:model_name) { "test_default" }
      let(:admin_directory) { "app/admin" }
      let(:active_admin_model_file_name) { "test_default.rb" }
      let(:relative_file_path) { File.join(admin_directory, active_admin_model_file_name) }
      let(:position_key) { :position_in_admin }

      before do
        FileUtils.mkdir_p(admin_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end
    end

    context "when including additional file patterns", :isolated_environment do
      let(:patterns) { ["spec/custom/%MODEL_NAME%_custom.rb"] }
      let(:options) { Annotaterb::Options.new(**include_nothing_options.merge({additional_file_patterns: patterns})) }

      let(:model_name) { "test_default" }
      let(:custom_directory) { "spec/custom" }
      let(:additional_file_name) { "test_default_custom.rb" }
      let(:relative_file_path) { File.join(custom_directory, additional_file_name) }
      let(:position_key) { :position_in_additional_file_patterns }

      before do
        FileUtils.mkdir_p(custom_directory)
        FileUtils.touch(relative_file_path)
      end

      it "returns the test file and the position key" do
        expect(subject).to eq([[relative_file_path, position_key]])
      end
    end
  end
end
