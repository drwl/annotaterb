## AnnotateRb
### forked from the [Annotate aka AnnotateModels gem](https://github.com/ctran/annotate_models)

----------
[![CI](https://github.com/drwl/annotaterb/actions/workflows/ci.yml/badge.svg)](https://github.com/drwl/annotaterb/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/annotaterb.svg)](https://badge.fury.io/rb/annotaterb)

Adds comments summarizing the model schema or routes in your:

- ActiveRecord models
- Fixture files
- Tests and Specs
- FactoryBot factories
- `routes.rb` file (for Rails projects)

The schema comment looks like this:

```ruby
# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  content    :string
#  count      :integer
#  status     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Task < ApplicationRecord
  ...
```
----------
## Installation

```sh
$ gem install annotaterb
```

Or install it into your Rails project through the Gemfile:

```rb
group :development do
  ...

  gem "annotaterb"
  
  ...
```

### Automatically annotate models
For Rails projects, model files can get automatically annotated after migration tasks. To do this, run the following command:

```sh
$ bin/rails g annotate_rb:install
```

This will copy a rake task into your Rails project's `lib/tasks` directory that will hook into the Rails project rake tasks, automatically running AnnotateRb after database migration rake tasks.

## Migrating from the annotate gem

Add steps for migrating from annotate gem.

## Usage

AnnotateRb has a CLI that you can use to add or remove annotations.

```sh
# To show the CLI options
$ bundle exec annotaterb 
```

## Configuration


### How to skip annotating a particular model
If you want to always skip annotations on a particular model, add this string
anywhere in the file:

    # -*- SkipSchemaAnnotations

## Sorting

By default, columns will be sorted in database order (i.e. the order in which
migrations were run).

If you prefer to sort alphabetically so that the results of annotation are
consistent regardless of what order migrations are executed in, use `--sort`.

## License

Released under the same license as Ruby. No Support. No Warranty.
