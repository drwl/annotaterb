RSpec.describe AnnotateRb::ModelAnnotator::SingleFileAnnotationRemover do
  describe ".call" do
    subject { described_class.call(path) }

    let(:tmpdir) do
      Dir.mktmpdir("annotate_rb")
    end

    let(:filename) { "some_file.rb" }

    let(:path) do
      File.join(tmpdir, filename).tap do |path|
        File.open(path, "w") do |f|
          f.puts(file_content)
        end
      end
    end

    let(:file_content_after_removal) do
      subject
      File.read(path)
    end

    let(:expected_result) do
      <<~EOS
        class Foo < ActiveRecord::Base
        end
      EOS
    end

    context "when annotation is before main content" do
      let(:file_content) do
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

      it "removes annotation" do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context "when annotation is before main content and CRLF is used for line breaks" do
      let(:file_content) do
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

      let(:expected_result) do
        <<~EOS

          class Foo < ActiveRecord::Base
          end
        EOS
      end

      it "removes annotation and leaves the extra new line" do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context "when annotation is before main content and with opening wrapper" do
      let(:file_content) do
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

      subject { described_class.call(path, AnnotateRb::Options.new({wrapper_open: "wrapper"})) }

      it "removes annotation" do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context "when annotation is before main content and with opening wrapper" do
      let(:file_content) do
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

      subject { described_class.call(path, AnnotateRb::Options.new({wrapper_open: "wrapper"})) }

      it "removes annotation" do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context "when annotation is after main content" do
      let(:file_content) do
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

      it "removes annotation" do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context "when annotation is after main content and with closing wrapper" do
      let(:file_content) do
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

      subject { described_class.call(path, AnnotateRb::Options.new({wrapper_close: "wrapper"})) }

      it "removes annotation" do
        expect(file_content_after_removal).to eq expected_result
      end
    end

    context 'when annotation is before main content and with comment "-*- SkipSchemaAnnotations"' do
      let(:file_content) do
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

      let(:expected_result) do
        file_content
      end

      it "does not remove annotation" do
        expect(file_content_after_removal).to eq expected_result
      end
    end
  end
end
