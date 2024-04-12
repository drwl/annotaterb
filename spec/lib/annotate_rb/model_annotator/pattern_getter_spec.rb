RSpec.describe AnnotateRb::ModelAnnotator::PatternGetter do
  describe ".call" do
    subject { described_class.call(options, pattern_type) }

    let(:options) { AnnotateRb::Options.new(base_options) }

    context 'when pattern_type is "additional_file_patterns"' do
      let(:pattern_type) { "additional_file_patterns" }

      context "when additional_file_patterns is specified in the options" do
        let(:base_options) { {root_dir: [""], additional_file_patterns: additional_file_patterns} }

        let(:additional_file_patterns) do
          [
            "/%PLURALIZED_MODEL_NAME%/**/*.rb",
            "/bar/%PLURALIZED_MODEL_NAME%/*_form"
          ]
        end

        it 'returns additional_file_patterns in the argument "options"' do
          is_expected.to eq(additional_file_patterns)
        end
      end

      context "when additional_file_patterns is not specified in the options" do
        let(:base_options) { {root_dir: [""]} }

        it "returns an empty array" do
          is_expected.to eq([])
        end
      end
    end

    context 'when pattern_type is "test"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "test" }

      it "returns patterns of test files" do
        is_expected.to eq([
          "test/unit/%MODEL_NAME%_test.rb",
          "test/models/%MODEL_NAME%_test.rb",
          "spec/models/%MODEL_NAME%_spec.rb"
        ])
      end
    end

    context 'when pattern_type is "fixture"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "fixture" }

      it "returns patterns of fixture files" do
        is_expected.to eq([
          "test/fixtures/%TABLE_NAME%.yml",
          "spec/fixtures/%TABLE_NAME%.yml",
          "test/fixtures/%PLURALIZED_MODEL_NAME%.yml",
          "spec/fixtures/%PLURALIZED_MODEL_NAME%.yml"
        ])
      end
    end

    context 'when pattern_type is "scaffold"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "scaffold" }

      it "returns patterns of scaffold files" do
        is_expected.to eq([
          "test/controllers/%PLURALIZED_MODEL_NAME%_controller_test.rb",
          "spec/controllers/%PLURALIZED_MODEL_NAME%_controller_spec.rb",
          "spec/requests/%PLURALIZED_MODEL_NAME%_spec.rb",
          "spec/routing/%PLURALIZED_MODEL_NAME%_routing_spec.rb"
        ])
      end
    end

    context 'when pattern_type is "factory"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "factory" }

      it "returns patterns of factory files" do
        is_expected.to eq([
          "test/exemplars/%MODEL_NAME%_exemplar.rb",
          "spec/exemplars/%MODEL_NAME%_exemplar.rb",
          "test/blueprints/%MODEL_NAME%_blueprint.rb",
          "spec/blueprints/%MODEL_NAME%_blueprint.rb",
          "test/factories/%MODEL_NAME%_factory.rb",
          "spec/factories/%MODEL_NAME%_factory.rb",
          "test/factories/%TABLE_NAME%.rb",
          "spec/factories/%TABLE_NAME%.rb",
          "test/factories/%PLURALIZED_MODEL_NAME%.rb",
          "spec/factories/%PLURALIZED_MODEL_NAME%.rb",
          "test/factories/%PLURALIZED_MODEL_NAME%_factory.rb",
          "spec/factories/%PLURALIZED_MODEL_NAME%_factory.rb",
          "test/fabricators/%MODEL_NAME%_fabricator.rb",
          "spec/fabricators/%MODEL_NAME%_fabricator.rb"
        ])
      end
    end

    context 'when pattern_type is "serializer"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "serializer" }

      it "returns patterns of serializer files" do
        is_expected.to eq([
          "app/serializers/%MODEL_NAME%_serializer.rb"
        ])
      end
    end

    context 'when pattern_type is "serializer_test"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "serializer_test" }

      it "returns patterns of serializer test files" do
        is_expected.to eq([
          "test/serializers/%MODEL_NAME%_serializer_test.rb",
          "spec/serializers/%MODEL_NAME%_serializer_spec.rb"
        ])
      end
    end

    context 'when pattern_type is "controller"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "controller" }

      it "returns patterns of controller files" do
        is_expected.to eq([
          "app/controllers/%PLURALIZED_MODEL_NAME%_controller.rb"
        ])
      end
    end

    context 'when pattern_type is "controller_test"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "controller_test" }

      it "returns patterns of controller files" do
        is_expected.to eq([
          "test/controllers/%PLURALIZED_MODEL_NAME%_controller_test.rb",
          "spec/controllers/%PLURALIZED_MODEL_NAME%_controller_spec.rb"
        ])
      end
    end

    context 'when pattern_type is "admin"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "admin" }

      it "returns both singular and pluralized model names" do
        is_expected.to eq([
          "app/admin/%MODEL_NAME%.rb", "app/admin/%PLURALIZED_MODEL_NAME%.rb"
        ])
      end
    end

    context 'when pattern_type is "helper"' do
      let(:base_options) { {root_dir: [""]} }
      let(:pattern_type) { "helper" }

      it "returns patterns of helper files" do
        is_expected.to eq([
          "app/helpers/%PLURALIZED_MODEL_NAME%_helper.rb"
        ])
      end
    end
  end
end
