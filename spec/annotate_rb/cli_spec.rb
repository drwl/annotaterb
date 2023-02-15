# frozen_string_literal: true

RSpec.describe AnnotateRb::CLI do
  subject(:cli) { described_class.new }

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  describe 'help option' do
    describe '-h/-?/--help' do
      it 'returns success exit code' do
        expect(cli.run(['-h'])).to eq(described_class::STATUS_SUCCESS)
        expect(cli.run(['-?'])).to eq(described_class::STATUS_SUCCESS)
        expect(cli.run(['--help'])).to eq(described_class::STATUS_SUCCESS)
      end

      it 'shows help text' do
        cli.run(['-h'])

        expected_help = <<~OUTPUT
          Inside AnnotateRb::Commands::Help
        OUTPUT

        expect($stdout.string).to eq(expected_help)
      end
    end
  end

  describe 'version option' do
    describe '-v/--version' do
      it 'returns success exit code' do
        expect(cli.run(['-v'])).to eq(described_class::STATUS_SUCCESS)
        expect(cli.run(['--version'])).to eq(described_class::STATUS_SUCCESS)
      end

      it 'shows version text' do
        cli.run(['-v'])

        expected_help = <<~OUTPUT
          Inside AnnotateRb::Commands::Version
        OUTPUT

        expect($stdout.string).to eq(expected_help)
      end
    end
  end

  describe 'annotate option' do
    describe 'random args' do
      let(:random_args) { ['random', 'arg'] }

      before do
        allow(AnnotateRb::Commands::Annotate).to receive(:run).with(random_args)
      end

      it 'forwards them' do
        cli.run(random_args)

        expect(AnnotateRb::Commands::Annotate).to have_received(:run).with(random_args)
      end
    end
  end
end
