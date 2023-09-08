# frozen_string_literal: true

require "pry"
require "aruba/rspec"

Aruba.configure do |config|
  config.allow_absolute_paths = true
end

module IntegrationTestHelper
  def self.ruby_version
    RUBY_VERSION.split(".").first(2).join("_") # => "3_0"
  end
end
