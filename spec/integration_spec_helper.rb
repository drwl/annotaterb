# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'pry'
require 'aruba/rspec'

Aruba.configure do |config|
  config.allow_absolute_paths = true
end
