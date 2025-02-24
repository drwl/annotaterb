# frozen_string_literal: true

module AnnotateTestHelpers
  def annotate_one_file(options = {})
    # Note: .from uses loads the defaults which can make it unclear what options are actually be loaded
    opts = Annotaterb::Options.from(options)

    Annotaterb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, @schema_info, :position_in_class, opts)
  end

  def write_model(file_name, file_content)
    fname = File.join(@model_dir, file_name)
    FileUtils.mkdir_p(File.dirname(fname))
    File.binwrite(fname, file_content)

    [fname, file_content]
  end

  def mock_index(name, params = {})
    double("IndexKeyDefinition",
      name: name,
      columns: params[:columns] || [],
      unique: params[:unique] || false,
      nulls_not_distinct: params[:nulls_not_distinct] || false,
      orders: params[:orders] || {},
      where: params[:where],
      using: params[:using])
  end

  def mock_foreign_key(name, from_column, to_table, to_column = "id", constraints = {})
    double("ForeignKeyDefinition",
      name: name,
      column: from_column,
      to_table: to_table,
      primary_key: to_column,
      on_delete: constraints[:on_delete],
      on_update: constraints[:on_update])
  end

  def mock_connection(indexes = [], foreign_keys = [], check_constraints = [], options = {})
    double_options = {
      indexes: indexes,
      check_constraints: check_constraints,
      foreign_keys: foreign_keys,
      supports_foreign_keys?: true,
      supports_check_constraints?: true
    }.merge(options)

    double("Conn", double_options)
  end

  def mock_connection_with_table_fields(indexes, foreign_keys, table_exists, table_comment)
    double("Conn with table fields",
      indexes: indexes,
      foreign_keys: foreign_keys,
      supports_foreign_keys?: true,
      table_exists?: table_exists,
      table_comment: table_comment)
  end

  def mock_class(table_name, primary_key, columns, indexes = [], foreign_keys = [])
    options = {
      connection: mock_connection(indexes, foreign_keys),
      table_exists?: true,
      table_name: table_name,
      primary_key: primary_key,
      column_names: columns.map { |col| col.name.to_s },
      columns: columns,
      column_defaults: columns.map { |col| [col.name, col.default] }.to_h,
      table_name_prefix: ""
    }

    double("An ActiveRecord class", options)
  end

  def mock_class_with_custom_connection(table_name, primary_key, columns, connection)
    options = {
      connection: connection,
      table_exists?: true,
      table_name: table_name,
      primary_key: primary_key,
      column_names: columns.map { |col| col.name.to_s },
      columns: columns,
      column_defaults: columns.map { |col| [col.name, col.default] }.to_h,
      table_name_prefix: ""
    }

    double("An ActiveRecord class", options)
  end

  def mock_column(name, type, options = {})
    default_options = {
      limit: nil,
      null: false,
      default: nil,
      sql_type: type
    }

    stubs = default_options.dup
    stubs.merge!(options)
    stubs[:name] = name
    stubs[:type] = type

    double("Column", stubs)
  end

  def mock_check_constraint(name, expression, validated = true)
    double("CheckConstraintDefinition",
      name: name,
      expression: expression,
      validated?: validated)
  end
end
