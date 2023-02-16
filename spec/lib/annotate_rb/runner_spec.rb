# frozen_string_literal: true

RSpec.describe AnnotateRb::Runner do
  subject(:runner) { described_class }

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  describe 'Annotating models' do
    let(:args) { ['models'] }

    it 'does stuff' do
      runner.run(args)

      expected_output = <<~OUTPUT
        Model mapping
      OUTPUT

      expect($stdout.string).to eq(expected_output)
    end
  end

  describe 'Annotating routes' do
    let(:args) { ['routes'] }

    it 'does stuff' do
      runner.run(args)

      expected_output = <<~OUTPUT
        Route mapping
      OUTPUT

      expect($stdout.string).to eq(expected_output)
    end
  end
end