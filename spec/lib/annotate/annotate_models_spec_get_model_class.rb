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

  describe '.get_model_class' do
    before :all do
      described_class.model_dir = Dir.mktmpdir('annotate_models')
    end

    # TODO: use 'files' gem instead
    def create(filename, file_content)
      File.join(AnnotateModels.model_dir[0], filename).tap do |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'wb') do |f|
          f.puts(file_content)
        end
      end
    end

    before do
      create(filename, file_content)
    end

    let :klass do
      described_class.get_model_class(File.join(described_class.model_dir[0], filename))
    end

    context 'when class Foo is defined in "foo.rb"' do
      let :filename do
        'foo.rb'
      end

      let :file_content do
        <<~EOS
          class Foo < ActiveRecord::Base
          end
        EOS
      end

      it 'works' do
        expect(klass.name).to eq('Foo')
      end
    end

    context 'when class name is not capitalized normally' do
      context 'when class FooWithCAPITALS is defined in "foo_with_capitals.rb"' do
        let :filename do
          'foo_with_capitals.rb'
        end

        let :file_content do
          <<~EOS
            class FooWithCAPITALS < ActiveRecord::Base
            end
          EOS
        end

        it 'works' do
          expect(klass.name).to eq('FooWithCAPITALS')
        end
      end
    end

    context 'when class is defined inside module' do
      context 'when class Bar::FooInsideBar is defined in "bar/foo_inside_bar.rb"' do
        let :filename do
          'bar/foo_inside_bar.rb'
        end

        let :file_content do
          <<~EOS
            module Bar
              class FooInsideBar < ActiveRecord::Base
              end
            end
          EOS
        end

        it 'works' do
          expect(klass.name).to eq('Bar::FooInsideBar')
        end
      end
    end

    context 'when class is defined inside module and class name is not capitalized normally' do
      context 'when class Bar::FooInsideCapitalsBAR is defined in "bar/foo_inside_capitals_bar.rb"' do
        let :filename do
          'bar/foo_inside_capitals_bar.rb'
        end

        let :file_content do
          <<~EOS
            module BAR
              class FooInsideCapitalsBAR < ActiveRecord::Base
              end
            end
          EOS
        end

        it 'works' do
          expect(klass.name).to eq('BAR::FooInsideCapitalsBAR')
        end
      end
    end

    context 'when unknown macros exist in class' do
      context 'when class FooWithMacro is defined in "foo_with_macro.rb"' do
        let :filename do
          'foo_with_macro.rb'
        end

        let :file_content do
          <<~EOS
            class FooWithMacro < ActiveRecord::Base
              acts_as_awesome :yah
            end
          EOS
        end

        it 'works and does not care about known macros' do
          expect(klass.name).to eq('FooWithMacro')
        end
      end

      context 'when class name is with ALL CAPS segments' do
        context 'when class is "FooWithCAPITALS" is defined in "foo_with_capitals.rb"' do
          let :filename do
            'foo_with_capitals.rb'
          end

          let :file_content do
            <<~EOS
              class FooWithCAPITALS < ActiveRecord::Base
                acts_as_awesome :yah
              end
            EOS
          end

          it 'works' do
            expect(klass.name).to eq('FooWithCAPITALS')
          end
        end
      end
    end

    context 'when known macros exist in class' do
      context 'when class FooWithKnownMacro is defined in "foo_with_known_macro.rb"' do
        let :filename do
          'foo_with_known_macro.rb'
        end

        let :file_content do
          <<~EOS
            class FooWithKnownMacro < ActiveRecord::Base
              has_many :yah
            end
          EOS
        end

        it 'works and does not care about known macros' do
          expect(klass.name).to eq('FooWithKnownMacro')
        end
      end
    end

    context 'when the file includes invalid multibyte chars (USASCII)' do
      context 'when class FooWithUtf8 is defined in "foo_with_utf8.rb"' do
        let :filename do
          'foo_with_utf8.rb'
        end

        let :file_content do
          <<~EOS
            # encoding: utf-8
            class FooWithUtf8 < ActiveRecord::Base
              UTF8STRINGS = %w[r??sum?? fa??on ??ge]
            end
          EOS
        end

        it 'works without complaining of invalid multibyte chars' do
          expect(klass.name).to eq('FooWithUtf8')
        end
      end
    end

    context 'when non-namespaced model is inside subdirectory' do
      context 'when class NonNamespacedFooInsideBar is defined in "bar/non_namespaced_foo_inside_bar.rb"' do
        let :filename do
          'bar/non_namespaced_foo_inside_bar.rb'
        end

        let :file_content do
          <<~EOS
            class NonNamespacedFooInsideBar < ActiveRecord::Base
            end
          EOS
        end

        it 'works' do
          expect(klass.name).to eq('NonNamespacedFooInsideBar')
        end
      end

      context 'when class name is not capitalized normally' do
        context 'when class NonNamespacedFooWithCapitalsInsideBar is defined in "bar/non_namespaced_foo_with_capitals_inside_bar.rb"' do
          let :filename do
            'bar/non_namespaced_foo_with_capitals_inside_bar.rb'
          end

          let :file_content do
            <<~EOS
              class NonNamespacedFooWithCapitalsInsideBar < ActiveRecord::Base
              end
            EOS
          end

          it 'works' do
            expect(klass.name).to eq('NonNamespacedFooWithCapitalsInsideBar')
          end
        end
      end
    end

    context 'when class file is loaded twice' do
      context 'when class LoadedClass is defined in "loaded_class.rb"' do
        let :filename do
          'loaded_class.rb'
        end

        let :file_content do
          <<~EOS
            class LoadedClass < ActiveRecord::Base
              CONSTANT = 1
            end
          EOS
        end

        before do
          path = File.expand_path(filename, described_class.model_dir[0])
          Kernel.load(path)
          expect(Kernel).not_to receive(:require)
        end

        it 'does not require model file twice' do
          expect(klass.name).to eq('LoadedClass')
        end
      end

      context 'when class is defined in a subdirectory' do
        dir = Array.new(8) { (0..9).to_a.sample(random: Random.new) }.join

        context "when class SubdirLoadedClass is defined in \"#{dir}/subdir_loaded_class.rb\"" do
          before do
            $LOAD_PATH.unshift(File.join(described_class.model_dir[0], dir))

            path = File.expand_path(filename, described_class.model_dir[0])
            Kernel.load(path)
            expect(Kernel).not_to receive(:require)
          end

          let :filename do
            "#{dir}/subdir_loaded_class.rb"
          end

          let :file_content do
            <<~EOS
              class SubdirLoadedClass < ActiveRecord::Base
                CONSTANT = 1
              end
            EOS
          end

          it 'does not require model file twice' do
            expect(klass.name).to eq('SubdirLoadedClass')
          end
        end
      end
    end

    context 'when two class exist' do
      before do
        create(filename_2, file_content_2)
      end

      context 'the base names are duplicated' do
        let :filename do
          'foo.rb'
        end

        let :file_content do
          <<-EOS
            class Foo < ActiveRecord::Base
            end
          EOS
        end

        let :filename_2 do
          'bar/foo.rb'
        end

        let :file_content_2 do
          <<-EOS
            class Bar::Foo < ActiveRecord::Base
            end
          EOS
        end

        let :klass_2 do
          described_class.get_model_class(File.join(described_class.model_dir[0], filename_2))
        end

        it 'finds valid model' do
          expect(klass.name).to eq('Foo')
          expect(klass_2.name).to eq('Bar::Foo')
        end
      end

      context 'the class name and base name clash' do
        let :filename do
          'foo.rb'
        end

        let :file_content do
          <<-EOS
            class Foo < ActiveRecord::Base
            end
          EOS
        end

        let :filename_2 do
          'bar/foo.rb'
        end

        let :file_content_2 do
          <<-EOS
            class Bar::Foo < ActiveRecord::Base
            end
          EOS
        end

        let :klass_2 do
          described_class.get_model_class(File.join(described_class.model_dir[0], filename_2))
        end

        it 'finds valid model' do
          expect(klass.name).to eq('Foo')
          expect(klass_2.name).to eq('Bar::Foo')
        end

        it 'attempts to load the model path without expanding if skip_subdirectory_model_load is false' do
          allow(described_class).to receive(:skip_subdirectory_model_load).and_return(false)
          full_path = File.join(described_class.model_dir[0], filename_2)
          expect(File).not_to receive(:expand_path).with(full_path)
          described_class.get_model_class(full_path)
        end

        it 'does not attempt to load the model path without expanding if skip_subdirectory_model_load is true' do
          $LOAD_PATH.unshift(described_class.model_dir[0])
          allow(described_class).to receive(:skip_subdirectory_model_load).and_return(true)
          full_path = File.join(described_class.model_dir[0], filename_2)
          expect(File).to receive(:expand_path).with(full_path).and_call_original
          described_class.get_model_class(full_path)
        end
      end

      context 'one of the classes is nested in another class' do
        let :filename do
          'voucher.rb'
        end

        let :file_content do
          <<-EOS
            class Voucher < ActiveRecord::Base
            end
          EOS
        end

        let :filename_2 do
          'voucher/foo.rb'
        end

        let :file_content_2 do
          <<~EOS
            class Voucher
              class Foo < ActiveRecord::Base
              end
            end
          EOS
        end

        let :klass_2 do
          described_class.get_model_class(File.join(described_class.model_dir[0], filename_2))
        end

        it 'finds valid model' do
          expect(klass.name).to eq('Voucher')
          expect(klass_2.name).to eq('Voucher::Foo')
        end
      end
    end
  end
end
