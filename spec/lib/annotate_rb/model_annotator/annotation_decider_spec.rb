require "spec_helper"

RSpec.describe AnnotateRb::ModelAnnotator::AnnotationDecider do
  subject { described_class.new(file, options).annotate? }

  let(:options) { AnnotateRb::Options.new }
  let(:file) { "any_file.rb" }

  before do
    # Default stub for a file that should not be skipped
    allow(File).to receive(:exist?).with(file).and_return(true)
    allow(File).to receive(:read).with(file).and_return("")
    allow(AnnotateRb::ModelAnnotator::ModelClassGetter).to receive(:call).with(file, options).and_return(model)
  end

  context "when the model is a standard ActiveRecord model" do
    let(:model) do
      double(
        "User",
        descends_from_active_record?: true,
        abstract_class?: false,
        table_exists?: true,
        base_class: double("User")
      )
    end
    it { is_expected.to be true }
  end

  context "when the model is an abstract class" do
    let(:model) do
      double(
        "ApplicationRecord",
        descends_from_active_record?: true,
        abstract_class?: true,
        table_exists?: false
      )
    end
    it { is_expected.to be false }
  end

  context "when the model is a class but does not descend from ActiveRecord::Base" do
    let(:model) do
      double(
        "NotAnArModel"
      )
    end
    it { is_expected.to be false }
  end

  context "when the model's table does not exist" do
    let(:model) do
      double(
        "NoTableUser",
        descends_from_active_record?: true,
        abstract_class?: false,
        table_exists?: false
      )
    end
    it { is_expected.to be false }
  end

  context "with an STI model" do
    let(:base_class) do
      double(
        "User",
        descends_from_active_record?: true,
        abstract_class?: false,
        table_exists?: true,
        base_class: double("User")
      )
    end

    context "when the model is the base class" do
      let(:model) { base_class }
      it { is_expected.to be true }
    end

    context "when the model is a subclass" do
      let(:model) do
        double(
          "Admin",
          descends_from_active_record?: false,
          abstract_class?: false,
          table_exists?: true,
          base_class: base_class
        )
      end

      context "and exclude_sti_subclasses is true" do
        let(:options) { AnnotateRb::Options.new(exclude_sti_subclasses: true) }
        it { is_expected.to be false }
      end

      context "and exclude_sti_subclasses is false" do
        let(:options) { AnnotateRb::Options.new(exclude_sti_subclasses: false) }
        it { is_expected.to be true }
      end
    end
  end

  context "when the file contains the skip comment" do
    before { allow(File).to receive(:read).with(file).and_return(skip_annotation_prefix) }

    let(:model) { double("User") } # Model getter won't even be called, but a double is needed
    let(:skip_annotation_prefix) { AnnotateRb::ModelAnnotator::AnnotationDecider::SKIP_ANNOTATION_PREFIX }
    it { is_expected.to be false }
  end
end
