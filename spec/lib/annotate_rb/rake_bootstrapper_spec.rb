# frozen_string_literal: true

RSpec.describe AnnotateRb::RakeBootstrapper do
  describe ".call" do
    subject { described_class.call }

    let(:invoked) { [] }

    around do |example|
      original_application = Rake.application
      Rake.application = Rake::Application.new
      example.run
    ensure
      Rake.application = original_application
    end

    before do
      calls = invoked
      Rake::Task.define_task(:environment) { calls << :environment }
    end

    it "loads the environment" do
      subject
      expect(invoked).to eq([:environment])
    end

    context "when activerecord-tenanted defines the `db:tenant` task" do
      before do
        calls = invoked
        Rake::Task.define_task("db:tenant") { calls << :tenant }
      end

      it "sets the default tenant after loading the environment" do
        subject
        expect(invoked).to eq([:environment, :tenant])
      end
    end
  end
end
