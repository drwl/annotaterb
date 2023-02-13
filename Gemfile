source 'https://rubygems.org'
gemspec

gem 'activerecord', require: false
gem 'rake'
gem 'rspec'

group :development, :test do
  gem 'byebug'
  gem 'guard-rspec', require: false

  gem 'terminal-notifier-guard', require: false

  gem 'overcommit'

  platforms :mri, :mingw do
    gem 'pry', require: false
    gem 'pry-byebug', require: false
  end
end

group :test do
  gem 'files', require: false
  gem 'git', require: false
end
