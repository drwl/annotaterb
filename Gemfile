# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake"
gem "bigdecimal"
gem "mutex_m"

group :development, :test do
  gem "aruba", "~> 2.1.0", require: false
  gem "byebug"
  gem "guard-rspec", require: false

  gem "rspec"

  gem "standard", "~> 1.29.0"
  gem "terminal-notifier-guard", require: false

  platforms :mri, :mingw do
    gem "pry", require: false
    gem "pry-byebug", require: false
  end
end
