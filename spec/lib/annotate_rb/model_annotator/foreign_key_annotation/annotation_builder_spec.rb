# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ForeignKeyAnnotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(model, options).build }
    let(:default_format) { subject.to_default }
    let(:markdown_format) { subject.to_markdown }

    let(:model) do
      klass = begin
        primary_key = nil
        columns = []
        indexes = []

        mock_class(
          :users,
          primary_key,
          columns,
          indexes,
          foreign_keys
        )
      end

      ::AnnotateRb::ModelAnnotator::ModelWrapper.new(klass, options)
    end
    let(:options) { ::AnnotateRb::Options.new({show_foreign_keys: true, show_complete_foreign_keys: true}) }

    context "when show_foreign_keys option is false" do
      let(:foreign_keys) { [] }
      let(:options) { ::AnnotateRb::Options.new({show_foreign_keys: false}) }

      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "without foreign keys" do
      let(:foreign_keys) { [] }

      it { expect(default_format).to be_nil }
    end

    context "with foreign keys" do
      let(:foreign_keys) do
        [
          mock_foreign_key("fk_rails_cf2568e89e", "foreign_thing_id", "foreign_things"),
          mock_foreign_key("custom_fk_name", "other_thing_id", "other_things"),
          mock_foreign_key("fk_rails_a70234b26c", "third_thing_id", "third_things")
        ]
      end
      let(:expected_output) do
        <<~OUTPUT.strip
          #
          # Foreign Keys
          #
          #  custom_fk_name       (other_thing_id => other_things.id)
          #  fk_rails_a70234b26c  (third_thing_id => third_things.id)
          #  fk_rails_cf2568e89e  (foreign_thing_id => foreign_things.id)
        OUTPUT
      end

      it { expect(default_format).to eq(expected_output) }

      context "in markdown format" do
        let(:expected_output) do
          <<~OUTPUT.strip
            #
            # ### Foreign Keys
            #
            # * `custom_fk_name`:
            #     * **`other_thing_id => other_things.id`**
            # * `fk_rails_a70234b26c`:
            #     * **`third_thing_id => third_things.id`**
            # * `fk_rails_cf2568e89e`:
            #     * **`foreign_thing_id => foreign_things.id`**
          OUTPUT
        end

        it { expect(markdown_format).to eq(expected_output) }
      end

      context "when show_complete_foreign_keys option is false" do
        let(:options) { ::AnnotateRb::Options.new({show_foreign_keys: true, show_complete_foreign_keys: false}) }

        let(:expected_output) do
          <<~OUTPUT.strip
            #
            # Foreign Keys
            #
            #  custom_fk_name  (other_thing_id => other_things.id)
            #  fk_rails_...    (foreign_thing_id => foreign_things.id)
            #  fk_rails_...    (third_thing_id => third_things.id)
          OUTPUT
        end

        it { expect(default_format).to eq(expected_output) }
      end
    end

    context "with a foreign key with options" do
      let(:foreign_keys) do
        [
          mock_foreign_key("fk_rails_02e851e3b7",
            "foreign_thing_id",
            "foreign_things",
            "id",
            on_delete: "on_delete_value",
            on_update: "on_update_value")
        ]
      end
      let(:expected_output) do
        <<~OUTPUT.strip
          #
          # Foreign Keys
          #
          #  fk_rails_02e851e3b7  (foreign_thing_id => foreign_things.id) ON DELETE => on_delete_value ON UPDATE => on_update_value
        OUTPUT
      end

      it { expect(default_format).to eq(expected_output) }
    end

    context "with a composite foreign key" do
      let(:foreign_keys) do
        [
          mock_foreign_key("fk_rails_cf2568e89e", "foreign_thing_id", "foreign_things"),
          mock_foreign_key("custom_fk_name", ["tenant_id", "customer_id"], "customers", ["tenant_id", "id"])
        ]
      end
      let(:expected_output) do
        <<~OUTPUT.strip
          #
          # Foreign Keys
          #
          #  custom_fk_name       ([tenant_id, customer_id] => customers.[tenant_id, id])
          #  fk_rails_cf2568e89e  (foreign_thing_id => foreign_things.id)
        OUTPUT
      end

      it { expect(default_format).to eq(expected_output) }

      context "in markdown format" do
        let(:expected_output) do
          <<~OUTPUT.strip
            #
            # ### Foreign Keys
            #
            # * `custom_fk_name`:
            #     * **`[tenant_id, customer_id] => customers.[tenant_id, id]`**
            # * `fk_rails_cf2568e89e`:
            #     * **`foreign_thing_id => foreign_things.id`**
          OUTPUT
        end

        it { expect(markdown_format).to eq(expected_output) }
      end
    end
  end
end
