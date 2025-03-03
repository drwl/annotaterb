# frozen_string_literal: true

require "bundler"
require "bundler/gem_helper"
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

task default: ["spec:unit"]

base_dir = File.join(File.dirname(__FILE__))
helper = Bundler::GemHelper.new(base_dir)

helper.install
