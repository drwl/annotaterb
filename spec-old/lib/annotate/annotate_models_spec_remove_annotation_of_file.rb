require 'annotate/annotate_models'
require 'annotate/active_record_patch'
require 'active_support/core_ext/string'
require 'files'
require 'tmpdir'

RSpec.describe AnnotateModels do
  unless const_defined?(:MAGIC_COMMENTS)
    MAGIC_COMMENTS = [
      '# encoding: UTF-8',
      '# coding: UTF-8',
      '# -*- coding: UTF-8 -*-',
      '#encoding: utf-8',
      '# encoding: utf-8',
      '# -*- encoding : utf-8 -*-',
      "# encoding: utf-8\n# frozen_string_literal: true",
      "# frozen_string_literal: true\n# encoding: utf-8",
      '# frozen_string_literal: true',
      '#frozen_string_literal: false',
      '# -*- frozen_string_literal : true -*-'
    ].freeze
  end

  def mock_index(name, params = {})
    double('IndexKeyDefinition',
           name: name,
           columns: params[:columns] || [],
           unique: params[:unique] || false,
           orders: params[:orders] || {},
           where: params[:where],
           using: params[:using])
  end

  def mock_foreign_key(name, from_column, to_table, to_column = 'id', constraints = {})
    double('ForeignKeyDefinition',
           name: name,
           column: from_column,
           to_table: to_table,
           primary_key: to_column,
           on_delete: constraints[:on_delete],
           on_update: constraints[:on_update])
  end

  def mock_connection(indexes = [], foreign_keys = [])
    double('Conn',
           indexes: indexes,
           foreign_keys: foreign_keys,
           supports_foreign_keys?: true)
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
      table_name_prefix: ''
    }

    double('An ActiveRecord class', options)
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

    double('Column', stubs)
  end

  describe '.remove_annotation_of_file' do
    subject do
      described_class.remove_annotation_of_file(path)
    end

    let :tmpdir do
      Dir.mktmpdir('annotate_models')
    end

    let :path do
      File.join(tmpdir, filename).tap do |path|
        File.open(path, 'w') do |f|
          f.puts(file_content)
        end
      end
    end

    let :file_content_after_removal do
      subject
      File.read(path)
    end

    let :expected_result do
      <<~EOS
        class Foo < ActiveRecord::Base
        end
      EOS
    end

    context 'when annotation is before main content' do
      let :filename do
        'before.rb'
      end

      let :file_content do
        <<~EOS
          # == Schema Information
          #
          # Table name: foo
          #
          #  id                  :integer         not null, primary key
          #  created_at          :datetime
          #  updated_at          :datetime
          #

          class Foo < ActiveRecord::Base
          end
        EOS
      end

      it 'removes annotation' do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context 'when annotation is before main content and CRLF is used for line breaks' do
      let :filename do
        'before.rb'
      end

      let :file_content do
        <<~EOS
          # == Schema Information
          #
          # Table name: foo\r\n#
          #  id                  :integer         not null, primary key
          #  created_at          :datetime
          #  updated_at          :datetime
          #
          \r\n
          class Foo < ActiveRecord::Base
          end
        EOS
      end

      it 'removes annotation' do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context 'when annotation is before main content and with opening wrapper' do
      subject do
        described_class.remove_annotation_of_file(path, wrapper_open: 'wrapper')
      end

      let :filename do
        'opening_wrapper.rb'
      end

      let :file_content do
        <<~EOS
          # wrapper
          # == Schema Information
          #
          # Table name: foo
          #
          #  id                  :integer         not null, primary key
          #  created_at          :datetime
          #  updated_at          :datetime
          #

          class Foo < ActiveRecord::Base
          end
        EOS
      end

      it 'removes annotation' do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context 'when annotation is before main content and with opening wrapper' do
      subject do
        described_class.remove_annotation_of_file(path, wrapper_open: 'wrapper')
      end

      let :filename do
        'opening_wrapper.rb'
      end

      let :file_content do
        <<~EOS
          # wrapper\r\n# == Schema Information
          #
          # Table name: foo
          #
          #  id                  :integer         not null, primary key
          #  created_at          :datetime
          #  updated_at          :datetime
          #

          class Foo < ActiveRecord::Base
          end
        EOS
      end

      it 'removes annotation' do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context 'when annotation is after main content' do
      let :filename do
        'after.rb'
      end

      let :file_content do
        <<~EOS
          class Foo < ActiveRecord::Base
          end

          # == Schema Information
          #
          # Table name: foo
          #
          #  id                  :integer         not null, primary key
          #  created_at          :datetime
          #  updated_at          :datetime
          #

        EOS
      end

      it 'removes annotation' do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context 'when annotation is after main content and with closing wrapper' do
      subject do
        described_class.remove_annotation_of_file(path, wrapper_close: 'wrapper')
      end

      let :filename do
        'closing_wrapper.rb'
      end

      let :file_content do
        <<~EOS
          class Foo < ActiveRecord::Base
          end

          # == Schema Information
          #
          # Table name: foo
          #
          #  id                  :integer         not null, primary key
          #  created_at          :datetime
          #  updated_at          :datetime
          #
          # wrapper

        EOS
      end

      it 'removes annotation' do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context 'when annotation is before main content and with comment "-*- SkipSchemaAnnotations"' do
      let :filename do
        'skip.rb'
      end

      let :file_content do
        <<~EOS
          # -*- SkipSchemaAnnotations
          # == Schema Information
          #
          # Table name: foo
          #
          #  id                  :integer         not null, primary key
          #  created_at          :datetime
          #  updated_at          :datetime
          #

          class Foo < ActiveRecord::Base
          end
        EOS
      end

      let :expected_result do
        file_content
      end

      it 'does not remove annotation' do
        expect(file_content_after_removal).to eq expected_result
      end
    end
  end
end
