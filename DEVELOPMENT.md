# Development

After reading this file, you should have the necessary information to make changes to AnnotateRb.

## Context around testing

AnnotateRb is a tool that annotates ActiveRecord model files with their model schema. At the time of writing, ActiveRecord has implementations for Postgres, SQLite3, MySQL, and Trilogy, although it should support other adapters. 
Databases and adapters can differ in their behaviors, so it's important to test run unit tests as well as integration tests with different adapters. 

An example of database adapter differences: when creating a model migration, SQLite represents the id field as a `:integer` and MySQL represents it as `:bigint`.

## What is `/spec/dummyapp`?

`/spec/dummyapp` contains a Rails app that is used in integration tests. It can be used for testing locally as well. 

When running `bundle install` within the context of dummyapp, specifying `DATABASE_ADAPTER` is required, possible values at the time of writing are `mysql2, pg, sqlite3`. 
This environment variable is required when running the dummyapp.

## On testing

AnnotateRb uses RSpec as a testing framework for unit tests.

AnnotateRb uses RSpec + Aruba to run integration tests.

I have found integration tests hard to write because we are testing a command line interface. As far as I'm aware, there aren't ways to easily debug it (i.e. add `binding.pry` or `binding.irb` statements) due to RSpec + Aruba.

**If there is a better way to do this, please let me know.**

## Writing integration test

Refer to git history for examples of previous commits. 

When I run into errors with newly written integration tests, I run the gem in the context of the dummyapp (spec/dummyapp) using `DATABASE_ADAPTER=sqlite3 bundle exec annotaterb models` with debug statements.

## Linter

AnnotateRb uses [StandardRb](https://github.com/standardrb/standard). This is open to changing in the future, but was chosen early on to spend as little time on configuring Rubocop.

## Development flow
**If you intend to run integration tests locally, you will need to install the dependencies for dummyapp and setup the respective databases before being able to run them.**

1. Fork the repo
2. Make necessary changes
3. Run unit tests: `bundle exec rake spec:unit`
4. optional: Run integration tests `DATABASE_ADAPTER=sqlite3 bundle exec rake spec:integration` (setup)
5. Run StandardRb (linter) `bundle exec standardrb`, optionally can fix files using command `bundle exec standardrb --fix` (note: this can and will make changes to files)
6. Submit a pull request

