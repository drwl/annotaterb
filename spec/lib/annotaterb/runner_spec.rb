# frozen_string_literal: true

RSpec.describe AnnotateRb::Runner do
  subject(:runner) { described_class.new }

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  describe "help option" do
    describe "-h/-?/--help" do
      it "shows help text" do
        runner.run(["-h"])

        expect($stdout.string).to include(AnnotateRb::Parser::BANNER_STRING)
      end
    end

    describe "help" do
      it "shows help text" do
        runner.run(["help"])

        expect($stdout.string).to include(AnnotateRb::Parser::BANNER_STRING)
      end
    end
  end

  describe "version option" do
    describe "-v/--version" do
      it "shows version text" do
        runner.run(["-v"])

        version_string = AnnotateRb::Core.version

        expect($stdout.string).to include(version_string)
      end
    end

    describe "version" do
      it "shows version text" do
        runner.run(["version"])

        version_string = AnnotateRb::Core.version

        expect($stdout.string).to include(version_string)
      end
    end
  end

  describe "Annotating models" do
    let(:args) { ["models"] }
    let(:command_double) { instance_double(AnnotateRb::Commands::AnnotateModels) }

    before do
      allow(AnnotateRb::Commands::AnnotateModels).to receive(:new).and_return(command_double)
      allow(command_double).to receive(:call)
    end

    it "calls the annotate models command" do
      runner.run(args)

      expect(command_double).to have_received(:call)
    end
  end

  describe "Annotating routes" do
    let(:args) { ["routes"] }
    let(:command_double) { instance_double(AnnotateRb::Commands::AnnotateRoutes) }

    before do
      allow(AnnotateRb::Commands::AnnotateRoutes).to receive(:new).and_return(command_double)
      allow(command_double).to receive(:call)
    end

    it "calls the annotate routes command" do
      runner.run(args)

      expect(command_double).to have_received(:call)
    end
  end
end
