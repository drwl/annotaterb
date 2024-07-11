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
    let(:options) { ::AnnotateRb::Options.new({show_complete_foreign_keys: true}) }

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
        <<~OUTPUT
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
          <<~OUTPUT
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
    end

    context "with a composite foreign key" do
      let(:foreign_keys) do
        [
          mock_foreign_key("fk_rails_cf2568e89e", "foreign_thing_id", "foreign_things"),
          mock_foreign_key("custom_fk_name", ["tenant_id", "customer_id"], "customers", ["tenant_id", "id"])
        ]
      end
      let(:expected_output) do
        <<~OUTPUT
          #
          # Foreign Keys
          #
          #  custom_fk_name       ([tenant_id, customer_id] => customers[tenant_id, id])
          #  fk_rails_cf2568e89e  (foreign_thing_id => foreign_things.id)
        OUTPUT
      end

      it { expect(default_format).to eq(expected_output) }

      context "in markdown format" do
        let(:expected_output) do
          <<~OUTPUT
            #
            # ### Foreign Keys
            #
            # * `custom_fk_name`:
            #     * **`[tenant_id, customer_id] => customers[tenant_id, id]`**
            # * `fk_rails_cf2568e89e`:
            #     * **`foreign_thing_id => foreign_things.id`**
          OUTPUT
        end

        it { expect(markdown_format).to eq(expected_output) }
      end
    end
  end
end
