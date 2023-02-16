RSpec.describe AnnotateRb::Core do
  describe '.version' do
    subject { described_class.version }

    it { is_expected.to be_a(String) }
  end
end
