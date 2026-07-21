## AnnotateRb

### forked from the [Annotate aka AnnotateModels gem](https://github.com/ctran/annotate_models)

A Ruby Gem that adds annotations to your Rails models and route files.

---

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

---

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

```sh
$ bin/rails db:migrate
# ...
# Annotating models
# Annotated (1): app/models/task.rb
```

To skip the automatic annotation that happens after a db task, pass the environment variable `ANNOTATERB_SKIP_ON_DB_TASKS=1` before your command.

```sh
$ ANNOTATERB_SKIP_ON_DB_TASKS=1 bin/rails db:migrate
```

### Added Rails generators

The following Rails generator commands get added.

```sh
$ bin/rails generate --help

...

AnnotateRb:
  annotate_rb:config
  annotate_rb:hook
  annotate_rb:install
  annotate_rb:update_config
...

```

`bin/rails g annotate_rb:config`

- Generates a new configuration file, `.annotaterb.yml`, using defaults from the gem.

`bin/rails g annotate_rb:hook`

- Installs the Rake file to automatically annotate Rails models on a database task (e.g. AnnotateRb will automatically run after running `bin/rails db:migrate`).

`bin/rails g annotate_rb:install`

- Runs the `config` and `hook` generator commands

`bin/rails g annotate_rb:update_config`

- Appends to `.annotaterb.yml` any configuration key-value pairs that are used by the Gem. This is useful when there's a drift between the config file values and the gem defaults (i.e. when new features get added).

## Migrating from the annotate gem

Refer to the [migration guide](MIGRATION_GUIDE.md).

## Usage

AnnotateRb has a CLI that you can use to add or remove annotations.

```sh
# To show the CLI options
$ bundle exec annotaterb

Usage: annotaterb [command] [options]

Commands:
    models [options]
    routes [options]
    help
    version

Options:
    -v, --version                    Display the version..
    -h, --help                       You're looking at it.

Annotate model options:
    Usage: annotaterb models [options]

    -a, --active-admin               Annotate active_admin models
        --show-migration             Include the migration version number in the annotation
    -k, --show-foreign-keys          List the table's foreign key constraints in the annotation
        --ck, --complete-foreign-keys
                                     Complete foreign key names in the annotation
    -i, --show-indexes               List the table's database indexes in the annotation
    -s, --simple-indexes             Concat the column's related indexes in the annotation
    -c, --show-check-constraints     List the table's check constraints in the annotation
        --hide-limit-column-types VALUES
                                     don't show limit for given column types, separated by commas (i.e., `integer,boolean,text`)
        --hide-default-column-types VALUES
                                     don't show default for given column types, separated by commas (i.e., `json,jsonb,hstore`)
        --ignore-unknown-models      don't display warnings for bad model files
    -I, --ignore-columns REGEX       don't annotate columns that match a given REGEX (i.e., `annotate -I '^(id|updated_at|created_at)'`
        --with-comment               include database comments in model annotations
        --without-comment            exclude database comments in model annotations
        --with-column-comments       include column comments in model annotations
        --without-column-comments    exclude column comments in model annotations
        --position-of-column-comment [with_name|rightmost_column]
                                     set the position, in the annotation block, of the column comment
        --with-table-comments        include table comments in model annotations
        --without-table-comments     exclude table comments in model annotations
        --classes-default-to-s class Custom classes to be represented with `to_s`, may be used multiple times
        --nested-position            Place annotations directly above nested classes or modules instead of at the top of the file.

Annotate routes options:
    Usage: annotaterb routes [options]

        --ignore-routes REGEX        don't annotate routes that match a given REGEX (i.e., `annotate -I '(mobile|resque|pghero)'`
        --timestamp                  Include timestamp in (routes) annotation
        --w, --wrapper STR           Wrap annotation with the text passed as parameter.
                                     If --w option is used, the same text will be used as opening and closing
        --wo, --wrapper-open STR     Annotation wrapper opening.
        --wc, --wrapper-close STR    Annotation wrapper closing

Command options:
Additional options that work for annotating models and routes

        --additional-file-patterns path1,path2,path3
                                     Additional file paths or globs to annotate, separated by commas (e.g. `/foo/bar/%MODEL_NAME%/*.rb,/baz/%MODEL_NAME%.rb`)
    -d, --delete                     Remove annotations from all model files or the routes.rb file
        --model-dir dir              Annotate model files stored in dir rather than app/models, separate multiple dirs with commas
        --root-dir dir               Annotate files stored within root dir projects, separate multiple dirs with commas
        --ignore-model-subdirects    Ignore subdirectories of the models directory
        --sort                       Sort columns alphabetically, rather than in creation order
        --classified-sort            Sort columns alphabetically, but first goes id, then the rest columns, then the timestamp columns and then the association columns
        --grouped-polymorphic        Group polymorphic associations together in the annotation when using --classified-sort
    -R, --require path               Additional file to require before loading models, may be used multiple times
    -e [tests,fixtures,factories,serializers],
        --exclude                    Do not annotate fixtures, test files, factories, and/or serializers
    -f [bare|rdoc|yard|markdown],    Render Schema Information as plain/RDoc/Yard/Markdown
        --format
        --config_path [path]         Path to configuration file (by default, .annotaterb.yml in the root of the project)
    -p [before|top|after|bottom|before_doc],
        --position                   Place the annotations at the top (before), bottom (after), or above the class documentation (before_doc) of the model/test/fixture/factory/route/serializer file(s)
        --pc, --position-in-class [before|top|after|bottom|before_doc]
                                     Place the annotations at the top (before), bottom (after), or above the class documentation (before_doc) of the model file
        --pf, --position-in-factory [before|top|after|bottom]
                                     Place the annotations at the top (before) or the bottom (after) of any factory files
        --px, --position-in-fixture [before|top|after|bottom]
                                     Place the annotations at the top (before) or the bottom (after) of any fixture files
        --pt, --position-in-test [before|top|after|bottom]
                                     Place the annotations at the top (before) or the bottom (after) of any test files
        --pr, --position-in-routes [before|top|after|bottom]
                                     Place the annotations at the top (before) or the bottom (after) of the routes.rb file
        --ps, --position-in-serializer [before|top|after|bottom]
                                     Place the annotations at the top (before) or the bottom (after) of the serializer files
        --pa, --position-in-additional-file-patterns [before|top|after|bottom]
                                     Place the annotations at the top (before) or the bottom (after) of files captured in additional file patterns
        --force                      Force new annotations even if there are no changes.
        --debug                      Prints the options and outputs messages to make it easier to debug.
        --frozen                     Do not allow to change annotations. Exits non-zero if there are going to be changes to files.
        --trace                      If unable to annotate a file, print the full stack trace, not just the exception message.
```

## Configuration

### Storing default options

Previously in the [Annotate](https://github.com/ctran/annotate_models) you could pass options through the CLI or store them as environment variables. Annotaterb removes dependency on the environment variables and instead can read values from a `.annotaterb.yml` file stored in the Rails project root.

### Configuration file location

AnnotateRb also supports other configuration file locations, and are searched for in the following locations (in order of precedence):
- `.annotaterb.yml`
- `config/annotaterb.yml`
- `.config/.annotaterb.yml`
- `.config/annotaterb/config.yml`

```yml
# .annotaterb.yml

position: after
```

Annotaterb reads first the configuration file, if it exists, passes its content through ERB, and merges the result with any options passed into the CLI.

For further details visit the [section in the migration guide](MIGRATION_GUIDE.md#automatic-annotations-after-running-database-migration-commands).

### Configuration options

Keys use snake_case and match the gem defaults in `AnnotateRb::Options`. CLI flags override values from the config file.

#### Position

| Option | Default | Description |
| --- | --- | --- |
| `position` | `before` | Fallback position for all `position_in_*` options. One of `before`, `top`, `after`, `bottom`, `before_doc`. |
| `position_in_class` | `before` | Position in model files. `before_doc` keeps class documentation adjacent to the class. |
| `position_in_factory` | `before` | Position in FactoryBot factory files. |
| `position_in_fixture` | `before` | Position in fixture files. |
| `position_in_test` | `before` | Position in test/spec files. |
| `position_in_routes` | `before` | Position in `config/routes.rb`. |
| `position_in_serializer` | `before` | Position in serializer files. |
| `position_in_additional_file_patterns` | `before` | Position in files matched by `additional_file_patterns`. |
| `nested_position` | `false` | Place annotations directly above nested classes/modules instead of at the top of the file. |

#### Schema annotation content

| Option | Default | Description |
| --- | --- | --- |
| `show_foreign_keys` | `true` | List foreign key constraints. |
| `show_complete_foreign_keys` | `false` | Use complete foreign key names. |
| `show_indexes` | `true` | List table indexes. |
| `show_indexes_comments` | `false` | Include index comments. |
| `show_indexes_include` | `false` | Include `INCLUDE` columns on indexes. |
| `simple_indexes` | `false` | Concat related indexes onto each column line. |
| `show_check_constraints` | `false` | List check constraints. |
| `show_enums` | `false` | Show PostgreSQL enum types. |
| `show_virtual_columns` | `false` | Show virtual/generated columns. |
| `include_version` | `false` | Include the migration version number. |
| `with_comment` | `true` | Include database comments (fallback for column/table comment flags). |
| `with_column_comments` | `true` | Include column comments. |
| `with_table_comments` | `true` | Include table comments. |
| `position_of_column_comment` | `with_name` | Column comment placement: `with_name` or `rightmost_column`. |
| `hide_default_column_types` | `""` | Comma-separated column types that omit defaults (e.g. `json,jsonb,hstore`). |
| `hide_limit_column_types` | `""` | Comma-separated column types that omit limits (e.g. `integer,boolean,text`). |
| `ignore_columns` | `null` | Regex of column names to skip. |
| `ignore_database_name` | `false` | Omit the database name from annotations. |
| `ignore_multi_database_name` | `false` | Omit the database name in multi-database setups. |
| `timestamp_columns` | `[created_at, updated_at]` | Column names treated as timestamps for classified sorting. |
| `classes_default_to_s` | `[]` | Class names whose default values are rendered with `to_s`. |

#### Sorting and format

| Option | Default | Description |
| --- | --- | --- |
| `sort` | `false` | Sort columns alphabetically. |
| `classified_sort` | `true` | Sort as id → other columns → timestamps → associations. |
| `grouped_polymorphic` | `false` | Group polymorphic associations when using `classified_sort`. |
| `format_markdown` | `false` | Render annotations as Markdown. |
| `format_rdoc` | `false` | Render annotations as RDoc. |
| `format_yard` | `false` | Render annotations as YARD. |

#### What to annotate / exclude

| Option | Default | Description |
| --- | --- | --- |
| `active_admin` | `false` | Annotate ActiveAdmin models. |
| `exclude_controllers` | `true` | Skip controller files. |
| `exclude_factories` | `false` | Skip factory files. |
| `exclude_fixtures` | `false` | Skip fixture files. |
| `exclude_helpers` | `true` | Skip helper files. |
| `exclude_scaffolds` | `true` | Skip scaffold files. |
| `exclude_serializers` | `false` | Skip serializer files. |
| `exclude_sti_subclasses` | `false` | Skip STI subclasses. |
| `exclude_tests` | `false` | Skip test/spec files. Can also be an array of symbols. |
| `ignore_model_sub_dir` | `false` | Ignore subdirectories under `model_dir`. |
| `ignore_unknown_models` | `false` | Suppress warnings for bad model files. |

#### Paths

| Option | Default | Description |
| --- | --- | --- |
| `model_dir` | `[app/models]` | Directories containing models. |
| `root_dir` | `[""]` | Root directories for multi-project layouts. |
| `additional_file_patterns` | `[]` | Extra paths/globs to annotate (supports `%MODEL_NAME%`). |
| `require` | `[]` | Extra files to require before loading models. |

#### Routes

| Option | Default | Description |
| --- | --- | --- |
| `ignore_routes` | `null` | Regex of routes to skip. |
| `timestamp` | `false` | Include a timestamp in route annotations. |
| `auto_annotate_routes_after_migrate` | `false` | Also annotate routes after DB migrate tasks. |

#### Wrappers and behavior

| Option | Default | Description |
| --- | --- | --- |
| `wrapper` | `null` | Text used for both opening and closing wrappers. |
| `wrapper_open` | `null` | Opening wrapper text (falls back to `wrapper`). |
| `wrapper_close` | `null` | Closing wrapper text (falls back to `wrapper`). |
| `force` | `false` | Rewrite annotations even when unchanged. |
| `frozen` | `false` | Exit non-zero if annotations would change. |
| `skip_on_db_migrate` | `false` | Skip automatic annotation after DB migrate tasks. |
| `debug` | `false` | Print resolved options for debugging. |
| `trace` | `false` | Print full stack traces when annotation fails. |

Example:

```yml
# .annotaterb.yml
position: after
show_foreign_keys: true
show_indexes: true
show_enums: true
classified_sort: true
model_dir:
  - app/models
  - app/models/concerns
skip_on_db_migrate: false
```

### Preserving class documentation comments

By default, when `position_in_class` is `before` (or `top`), AnnotateRb places the schema annotation immediately before the class declaration line. Any human-written documentation comment that was directly above the class is therefore pushed above the annotation.

If you prefer to keep the documentation comment adjacent to the class, set `position_in_class` to `before_doc`. The schema annotation is then inserted above the documentation comment block, leaving the comment directly before the class.

```ruby
# Source file:
# Doc about User
class User < ApplicationRecord
end

# With position_in_class: before  (default)
# Doc about User
# == Schema Information
# ...
class User < ApplicationRecord
end

# With position_in_class: before_doc
# == Schema Information
# ...
# Doc about User
class User < ApplicationRecord
end
```

A "documentation comment" is the contiguous comment block immediately above the class declaration, with no blank line between the comments and the class. Recognized magic comments (`encoding`, `frozen_string_literal`, `shareable_constant_value`, `warn_indent`, `typed`, `rbs_inline`, plus Emacs/Vim style modelines) are excluded so the annotation can still be inserted between magic comments and the class doc.

### How to skip annotating a particular model

If you want to always skip annotations on a particular model, add this string
anywhere in the file:

    # -*- SkipSchemaAnnotations

## Sorting

By default, columns will be sorted in database order (i.e. the order in which
migrations were run).

If you prefer to sort alphabetically so that the results of annotation are
consistent regardless of what order migrations are executed in, use `--sort`.

You can also sort columns by type, then alphabetically using `--classified-sort`
and `--grouped-polymorphic`: first goes id, then the rest columns, then the
timestamp columns and then the association columns.

## License

Released under the same license as Ruby. No Support. No Warranty.
