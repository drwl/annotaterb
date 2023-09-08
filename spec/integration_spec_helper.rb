# frozen_string_literal: true

require "pry"
require "aruba/rspec"

Aruba.configure do |config|
  config.allow_absolute_paths = true
end
