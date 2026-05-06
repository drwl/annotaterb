# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileParser::AnnotationTarget do
  describe ".find" do
    subject { described_class.find(parser, options, model_class_name: model_class_name) }

    let(:parser) { AnnotateRb::ModelAnnotator::FileParser::CustomParser.parse(content) }
    let(:options) { AnnotateRb::Options.new({nested_position: nested_position}) }
    let(:nested_position) { false }
    let(:model_class_name) { nil }

    context "with an empty file" do
      let(:content) { "" }

      it { is_expected.to be_nil }
    end

    context "with a single class" do
      let(:content) do
        <<~FILE
          class Sample < ApplicationRecord
          end
        FILE
      end

      it "returns the class start" do
        const, line = subject
        expect(const).to eq("Sample")
        expect(line).to eq(0)
      end
    end

    context "with a leading require" do
      let(:content) do
        <<~FILE
          require 'rails_helper'

          RSpec.describe Sample do
          end
        FILE
      end

      it "skips require and returns the first non-require start" do
        _const, line = subject
        expect(line).to eq(2)
      end
    end

    context "with a leading require_relative" do
      let(:content) do
        <<~FILE
          require_relative '../helper'

          class Sample < ApplicationRecord
          end
        FILE
      end

      it "skips require_relative" do
        const, line = subject
        expect(const).to eq("Sample")
        expect(line).to eq(2)
      end
    end

    context "with multiple require lines" do
      let(:content) do
        <<~FILE
          require 'rails_helper'
          require 'support/helper'
          require_relative '../local'

          RSpec.describe Sample do
          end
        FILE
      end

      it "skips all leading require directives" do
        _const, line = subject
        expect(line).to eq(4)
      end
    end

    context "with nested_position and a class referenced inside its own method body" do
      let(:nested_position) { true }
      let(:content) do
        <<~FILE
          class Sample < ApplicationRecord
            def call
              Sample.new
              Sample::Helper.run
            end
          end
        FILE
      end

      it "returns the class declaration line, not a later const reference" do
        const, line = subject
        expect(const).to eq("Sample")
        expect(line).to eq(0)
      end
    end

    context "with nested_position and a parent class referenced from an include path" do
      let(:nested_position) { true }
      let(:content) do
        <<~FILE
          module Alpha
            class Beta
              module Gamma
                class Delta < ApplicationRecord
                  include Alpha::Beta::Gamma::SomeMixin
                end
              end
            end
          end
        FILE
      end

      it "returns the deepest class, not a re-reference inside the body" do
        const, line = subject
        expect(const).to eq("Delta")
        expect(line).to eq(3)
      end
    end

    context "with nested_position and only modules" do
      let(:nested_position) { true }
      let(:content) do
        <<~FILE
          module Alpha
            module Beta
            end
          end
        FILE
      end

      it "falls back to the first non-require start when no class is found" do
        const, line = subject
        expect(const).to eq("Alpha")
        expect(line).to eq(0)
      end
    end

    context "with model_class_name set and a matching class declaration" do
      let(:nested_position) { true }
      let(:model_class_name) { "Sample" }
      let(:content) do
        <<~FILE
          module Outer
            class Sample < ApplicationRecord
              class InnerError < StandardError; end
              class InnerValue; end
            end
          end
        FILE
      end

      it "selects the named class instead of an inner class declared later" do
        const, line = subject
        expect(const).to eq("Sample")
        expect(line).to eq(1)
      end
    end

    context "with model_class_name that does not match any class in the source" do
      let(:nested_position) { true }
      let(:model_class_name) { "Unknown" }
      let(:content) do
        <<~FILE
          class Sample < ApplicationRecord
            class InnerError < StandardError; end
          end
        FILE
      end

      it "falls back to the deepest class declaration" do
        const, line = subject
        expect(const).to eq("InnerError")
        expect(line).to eq(1)
      end
    end

    context "with model_class_name set on a related file that has no class declarations" do
      let(:nested_position) { true }
      let(:model_class_name) { "Sample" }
      let(:content) do
        <<~FILE
          require 'rails_helper'

          RSpec.describe Sample do
          end
        FILE
      end

      it "falls back to the first non-require start" do
        _const, line = subject
        expect(line).to eq(2)
      end
    end
  end
end
