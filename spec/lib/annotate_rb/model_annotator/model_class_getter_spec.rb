RSpec.describe AnnotateRb::ModelAnnotator::ModelClassGetter do
  describe ".call" do
    def create(filename, file_content, options)
      model_dir_path = options[:model_dir][0]

      File.join(model_dir_path, filename).tap do |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, "wb") do |f|
          f.puts(file_content)
        end
      end
    end

    before do
      create(filename, file_content, options)
    end

    let(:options) { AnnotateRb::Options.new(base_options) }
    let(:base_options) { {model_dir: [Dir.mktmpdir("annotate_models")]} }
    let :klass do
      model_dir_path = options[:model_dir][0]

      described_class.call(File.join(model_dir_path, filename), options)
    end

    context 'when class Foo is defined in "foo.rb"' do
      let :filename do
        "foo.rb"
      end

      let :file_content do
        <<~EOS
          class Foo < ActiveRecord::Base
          end
        EOS
      end

      it "works" do
        expect(klass.name).to eq("Foo")
      end
    end

    context "when class name is not capitalized normally" do
      context 'when class FooWithCAPITALS is defined in "foo_with_capitals.rb"' do
        let :filename do
          "foo_with_capitals.rb"
        end

        let :file_content do
          <<~EOS
            class FooWithCAPITALS < ActiveRecord::Base
            end
          EOS
        end

        it "works" do
          expect(klass.name).to eq("FooWithCAPITALS")
        end
      end
    end

    context "when class is defined inside module" do
      context 'when class Bar::FooInsideBar is defined in "bar/foo_inside_bar.rb"' do
        let :filename do
          "bar/foo_inside_bar.rb"
        end

        let :file_content do
          <<~EOS
            module Bar
              class FooInsideBar < ActiveRecord::Base
              end
            end
          EOS
        end

        it "works" do
          expect(klass.name).to eq("Bar::FooInsideBar")
        end
      end
    end

    context "when class is defined inside module and class name is not capitalized normally" do
      context 'when class Bar::FooInsideCapitalsBAR is defined in "bar/foo_inside_capitals_bar.rb"' do
        let :filename do
          "bar/foo_inside_capitals_bar.rb"
        end

        let :file_content do
          <<~EOS
            module BAR
              class FooInsideCapitalsBAR < ActiveRecord::Base
              end
            end
          EOS
        end

        it "works" do
          expect(klass.name).to eq("BAR::FooInsideCapitalsBAR")
        end
      end
    end

    context "when known macros exist in class" do
      context 'when class FooWithKnownMacro is defined in "foo_with_known_macro.rb"' do
        let :filename do
          "foo_with_known_macro.rb"
        end

        let :file_content do
          <<~EOS
            class FooWithKnownMacro < ActiveRecord::Base
              has_many :yah
            end
          EOS
        end

        it "works and does not care about known macros" do
          expect(klass.name).to eq("FooWithKnownMacro")
        end
      end
    end

    context "when the file includes invlaid multibyte chars (USASCII)" do
      context 'when class FooWithUtf8 is defined in "foo_with_utf8.rb"' do
        let :filename do
          "foo_with_utf8.rb"
        end

        let :file_content do
          <<~EOS
            # encoding: utf-8
            class FooWithUtf8 < ActiveRecord::Base
              UTF8STRINGS = %w[résumé façon âge]
            end
          EOS
        end

        it "works without complaining of invalid multibyte chars" do
          expect(klass.name).to eq("FooWithUtf8")
        end
      end
    end

    context "when non-namespaced model is inside subdirectory" do
      context 'when class NonNamespacedFooInsideBar is defined in "bar/non_namespaced_foo_inside_bar.rb"' do
        let :filename do
          "bar/non_namespaced_foo_inside_bar.rb"
        end

        let :file_content do
          <<~EOS
            class NonNamespacedFooInsideBar < ActiveRecord::Base
            end
          EOS
        end

        it "works" do
          expect(klass.name).to eq("NonNamespacedFooInsideBar")
        end
      end

      context "when class name is not capitalized normally" do
        context 'when class NonNamespacedFooWithCapitalsInsideBar is defined in "bar/non_namespaced_foo_with_capitals_inside_bar.rb"' do
          let :filename do
            "bar/non_namespaced_foo_with_capitals_inside_bar.rb"
          end

          let :file_content do
            <<~EOS
              class NonNamespacedFooWithCapitalsInsideBar < ActiveRecord::Base
              end
            EOS
          end

          it "works" do
            expect(klass.name).to eq("NonNamespacedFooWithCapitalsInsideBar")
          end
        end
      end
    end

    context "when class file is loaded twice" do
      context 'when class LoadedClass is defined in "loaded_class.rb"' do
        let :filename do
          "loaded_class.rb"
        end

        let :file_content do
          <<~EOS
            class LoadedClass < ActiveRecord::Base
              CONSTANT = 1
            end
          EOS
        end

        before do
          model_dir_path = options[:model_dir][0]

          path = File.expand_path(filename, model_dir_path)
          Kernel.load(path)
          expect(Kernel).not_to receive(:require)
        end

        it "does not require model file twice" do
          expect(klass.name).to eq("LoadedClass")
        end
      end

      context "when class is defined in a subdirectory" do
        dir = Array.new(8) { (0..9).to_a.sample(random: Random.new) }.join

        context "when class SubdirLoadedClass is defined in \"#{dir}/subdir_loaded_class.rb\"" do
          before do
            model_dir_path = options[:model_dir][0]

            $LOAD_PATH.unshift(File.join(model_dir_path, dir))

            path = File.expand_path(filename, model_dir_path)
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

          it "does not require model file twice" do
            expect(klass.name).to eq("SubdirLoadedClass")
          end
        end
      end
    end

    context "when two class exist" do
      before do
        create(filename_2, file_content_2, options)
      end

      context "the base names are duplicated" do
        let :filename do
          "foo.rb"
        end

        let :file_content do
          <<-EOS
            class Foo < ActiveRecord::Base
            end
          EOS
        end

        let :filename_2 do
          "bar/foo.rb"
        end

        let :file_content_2 do
          <<-EOS
            module Bar; end
            class Bar::Foo
            end
          EOS
        end

        let :klass_2 do
          model_dir_path = options[:model_dir][0]

          described_class.call(File.join(model_dir_path, filename_2), options)
        end

        it "finds valid model" do
          expect(klass.name).to eq("Foo")
          expect(klass_2.name).to eq("Bar::Foo")
        end
      end

      context "one of the classes is nested in another class" do
        let :filename do
          "voucher.rb"
        end

        let :file_content do
          <<-EOS
            class Voucher < ActiveRecord::Base
            end
          EOS
        end

        let :filename_2 do
          "voucher/foo.rb"
        end

        let :file_content_2 do
          <<~EOS
            class Voucher
              class Foo
              end
            end
          EOS
        end

        let :klass_2 do
          model_dir_path = options[:model_dir][0]

          described_class.call(File.join(model_dir_path, filename_2), options)
        end

        it "finds valid model" do
          expect(klass.name).to eq("Voucher")
          expect(klass_2.name).to eq("Voucher::Foo")
        end
      end
    end
  end
end
