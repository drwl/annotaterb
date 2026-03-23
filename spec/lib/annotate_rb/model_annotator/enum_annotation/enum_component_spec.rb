# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::EnumAnnotation::EnumComponent do
  describe "#to_default" do
    it "formats the enum with name and values" do
      component = described_class.new("billing_method", ["agency_bill", "direct_bill_to_insured"], 20)
      expect(component.to_default).to eq("#  billing_method       agency_bill, direct_bill_to_insured")
    end

    it "pads the name to max_size" do
      component = described_class.new("status", ["active", "inactive"], 15)
      expect(component.to_default).to eq("#  status          active, inactive")
    end
  end

  describe "#to_markdown" do
    it "formats the enum in markdown" do
      component = described_class.new("billing_method", ["agency_bill", "direct_bill_to_insured"], 20)
      expect(component.to_markdown).to eq("# * `billing_method`: `agency_bill, direct_bill_to_insured`")
    end
  end
end
