# frozen_string_literal: true

require "bundler"
require "rspec/core/rake_task"

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |test|
    test.pattern = "spec/lib/**/*_spec.rb"
  end

  RSpec::Core::RakeTask.new(:integration) do |test|
    test.pattern = "spec/integration/**/*_spec.rb"
  end
end

task spec: ["spec:unit", "spec:integration"]

task default: :spec
