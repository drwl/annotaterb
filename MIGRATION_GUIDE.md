## Guide for migrating from Annotate to AnnotateRb
### Notable differences
* AnnotateRb drops support for older version of Ruby. At the time of writing, the minimum supported Ruby version is 2.7 as older versions have been end-of-life'd for sometime now.
* The command line interface has been changed to make commands easier to run annotations for models and routes separately. Refer to Command line differences section for more details.
* Configuration can now be done in a yml file instead of reading from ENV.
* No longer reads configuration options from ENV / environment variables.
* Annotate gem added 4 rake commands: `annotate_models`, `remove_annotation`, `annotate_routes`, `remove_routes` that were removed. If you use these and would like them back please open an issue.

----------

## Migration overview
Annotate provided 3 ways for passing options to the gem.
1. [Through the command line](#command-line-differences)
2. [Using environment variables (ENV)](#passing-options-via-environment-variables)
3. [Rake files that got installed](#automatic-annotations-after-running-database-migration-commands)

----------
### Command line differences
Previously, Annotate allowed you to annotate both model and route files in the same command. In an attempt to make the CLI easier to use, they are now separate. The following output is what you see when running annotaterb without any options. 

**Note: most of the options are similar with the following differences:**
* `--models` has been removed, to annotate models use `annotaterb models [options]` instead
* `-r`, `--routes` has been removed, to annotate routes use `annotaterb routes [options]` instead

If you notice any differences please [report an issue](https://github.com/drwl/annotaterb/issues/new) or [submit a pull request](https://github.com/drwl/annotaterb/pulls) to update this document.

```sh
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
    -k, --show-foreign-keys          List the table's foreign key
    ...

Annotate routes options:
    Usage: annotaterb routes [options]

        --ignore-routes REGEX        don't annotate routes that match a given REGEX (i.e., `annotate -I '(mobile|resque|pghero)'`
        ...
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
    -R, --require path               Additional file to require before loading models, may be used multiple times
    -e [tests,fixtures,factories,serializers],
        --exclude                    Do not annotate fixtures, test files, factories, and/or serializers
    ...
```

----------

### Passing options via Environment Variables
Annotate also reads options from ENV. For example, this command line argument `ANNOTATE_SKIP_ON_DB_MIGRATE=1 rake db:migrate` would affect Annotate's behavior. 

The reading from ENV / environment variables has **been removed** in favor of reading configuration from `.annotaterb.yml` file in your Rails project root.

```yml
# .annotaterb.yml

position: after
```

This change was done to reduce complexity in configuration and make the gem easier to maintain.

**Note: `.annotaterb.yml` is optional.** In its, AnnotateRb will use command line arguments and then the defaults. The defaults are implemented in `AnnotateRb::Options`.

----------

### Automatic annotations after running database migration commands
The old Annotate gem came with a generator that installed the following Rake file(s) into your Rails project.

```
lib/tasks/auto_annotate_models.rake
```

This rake task loaded other Annotate code that hooked into the Rails database migration rake tasks to automatically annotate after running database related tasks. 

**Before removing the file, make note of your favored defaults.** For example, you might see the following:

```ruby
    Annotate.set_defaults(
      'active_admin' => 'false',
      'additional_file_patterns' => [],
      'routes' => 'false',
      'models' => 'true',
      ...
```

These key-value pairs would go in the yml file mentioned above. After removing the rake task, run:

```sh
$ bin/rails g annotate_rb:install
```

to install AnnotateRb's equivalent file into your Rails project.

#### Default .annotaterb.yml
When running the install generator command, `bin/rails g annotate_rb:install`, an `.annotaterb.yml` file gets automatically generated for your project using the defaults from the gem. 

It _should_ match the old Annotate defaults however there may be differences.

**Note: there were bugs in Annotate that may have led to options not actually being used for some of the `exclude_*` options. If you experience different behavior despite using the same defaults then this may be why.**
