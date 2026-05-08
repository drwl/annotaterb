# frozen_string_literal: true

RSpec.describe AnnotateRb::Helper do
  describe ".width" do
    it "returns the length for ASCII strings" do
      expect(described_class.width("hello")).to eq(5)
    end

    it "returns 0 for an empty string" do
      expect(described_class.width("")).to eq(0)
    end

    it "counts CJK characters as width 2" do
      expect(described_class.width("日本語")).to eq(6)
    end

    it "counts fullwidth characters as width 2" do
      expect(described_class.width("Ａ")).to eq(2)
    end

    it "handles mixed ASCII and CJK characters" do
      # "ab" = 2, "漢字" = 4 => total 6
      expect(described_class.width("ab漢字")).to eq(6)
    end

    it "counts Hangul syllables as width 2" do
      # "한글" = 2 characters, each width 2
      expect(described_class.width("한글")).to eq(4)
    end
  end

  describe ".fallback" do
    it "returns the first non-blank value" do
      expect(described_class.fallback(nil, "", "first", "second")).to eq("first")
    end

    it "returns nil when all values are nil or blank" do
      expect(described_class.fallback(nil, "", nil)).to be_nil
    end

    it "returns the first argument if it is present" do
      expect(described_class.fallback("only")).to eq("only")
    end

    it "skips blank strings" do
      expect(described_class.fallback("", "  ", "value")).to eq("value")
    end
  end
end
