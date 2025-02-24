# frozen_string_literal: true

RSpec.describe Annotaterb::ModelAnnotator::SingleFileAnnotator do
  include AnnotateTestHelpers
  include AnnotateTestConstants

  describe ".call" do
    describe "annotating a file without annotations" do
      let(:options) { Annotaterb::Options.new({}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          class User < ActiveRecord::Base
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          class User < ActiveRecord::Base
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir("annotaterb")
        (@model_file_name, _file_content) = write_model("user.rb", starting_file_content)
      end

      it "writes the annotations to the file" do
        Annotaterb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe "annotating a file with old annotations" do
      let(:options) { Annotaterb::Options.new({}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir("annotaterb")
        (@model_file_name, _file_content) = write_model("user.rb", starting_file_content)
      end

      it "updates the annotations" do
        Annotaterb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe 'annotating a file with existing annotations (position: after) using position: "before" and force: false' do
      let(:options) { Annotaterb::Options.new({position_in_class: "before", force: false}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          class User < ApplicationRecord
          end

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          class User < ApplicationRecord
          end

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir("annotaterb")
        (@model_file_name, _file_content) = write_model("user.rb", starting_file_content)
      end

      it "updates the annotations without changing the position" do
        Annotaterb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe 'annotating a file with existing annotations (position: after) using position: "before" and force: true' do
      let(:options) { Annotaterb::Options.new({position_in_class: "before", force: true}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          class User < ApplicationRecord
          end

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir("annotaterb")
        (@model_file_name, _file_content) = write_model("user.rb", starting_file_content)
      end

      it "replaces the annotations using the new position" do
        Annotaterb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe "annotating a file with old annotations and magic comments" do
      let(:options) { Annotaterb::Options.new({}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # typed: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # typed: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir("annotaterb")
        (@model_file_name, _file_content) = write_model("user.rb", starting_file_content)
      end

      it "updates the annotations" do
        Annotaterb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe "annotating a file with existing column comments" do
      let(:options) { Annotaterb::Options.new({with_comment: true}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                       :integer          not null, primary key
          #  name([sensitivity: low]) :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir("annotaterb")
        (@model_file_name, _file_content) = write_model("user.rb", starting_file_content)

        @klass = mock_class(:users,
          :id,
          [
            # Having `comment: nil` for id column is the "correct" test setup
            # Only MySQL and PostgreSQL adapters support comments AND ModelWrapper#with_comments?
            # expects the first column to respond to `comment` method before checking the rest.
            mock_column("id", :integer, comment: nil),
            mock_column("name", :string, limit: 50, comment: "[sensitivity: medium]")
          ])
      end

      it "updates the annotations" do
        Annotaterb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe "annotating a yml file with erb with position before" do
      let(:options) { Annotaterb::Options.new({with_comment: true, position_in_fixture: "before"}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #  email                       :string
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          # Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html

          <% 1.upto(100) do |i| %>
          user_<%= i %>:
            name: User <%= i %>
            email: user_<%= i %>@example.com
          <% end %>

        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html

          <% 1.upto(100) do |i| %>
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #  email                       :string
          #
          user_<%= i %>:
            name: User <%= i %>
            email: user_<%= i %>@example.com
          <% end %>

        FILE
      end

      before do
        @model_dir = Dir.mktmpdir("annotaterb")
        (@model_file_name, _file_content) = write_model("user.yml", starting_file_content)
      end

      it "updates the annotations" do
        described_class.call(@model_file_name, schema_info, :position_in_fixture, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe "annotating a yml file with erb with position after" do
      let(:options) { Annotaterb::Options.new({with_comment: true, position_in_fixture: "after"}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #  email                       :string
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          # Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html

          <% 1.upto(100) do |i| %>
          user_<%= i %>:
            name: User <%= i %>
            email: user_<%= i %>@example.com
          <% end %>

        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html

          <% 1.upto(100) do |i| %>
          user_<%= i %>:
            name: User <%= i %>
            email: user_<%= i %>@example.com
          <% end %>


          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #  email                       :string
          #
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir("annotaterb")
        (@model_file_name, _file_content) = write_model("user.yml", starting_file_content)
      end

      it "updates the annotations" do
        described_class.call(@model_file_name, schema_info, :position_in_fixture, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end
  end
end
