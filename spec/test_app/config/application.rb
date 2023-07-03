# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_record/railtie'

module AnnotateRb
  class Application < Rails::Application
    config.load_defaults "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"
    config.root = File.expand_path(File.join(__FILE__, '../../../test_app'))
    config.eager_load = false
    config.active_record.legacy_connection_handling = false if Rails.gem_version >= Gem::Version.new('7.0')
  end
end
