# frozen_string_literal: true

source 'https://rubygems.org'

gem "activerecord", require: false
gem "rake"
gem "rspec"

group :development, :test do
  gem "aruba", "~> 2.1.0", require: false
  gem "byebug"
  gem "guard-rspec", require: false

  gem "standard", "~> 1.29.0"
  gem "terminal-notifier-guard", require: false

  platforms :mri, :mingw do
    gem "pry", require: false
    gem "pry-byebug", require: false
  end
end

group :test do
  gem 'mysql2', '>= 0.5', '< 1', require: false
  gem 'pg', '>= 1.5', '< 2', require: false
  gem 'rails', '>= 6.1', '< 7.1', require: false
  gem 'sqlite3', '>= 1.6', '< 2', require: false
end

gemspec
