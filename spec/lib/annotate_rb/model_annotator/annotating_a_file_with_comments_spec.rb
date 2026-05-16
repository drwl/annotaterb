# frozen_string_literal: true

RSpec.describe "Annotating a file with comments" do
  include AnnotateTestHelpers
  include AnnotateTestConstants

  shared_examples "annotates the file" do
    it "writes the expected annotations to the file" do
      AnnotateRb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options, model_class_name: model_class_name)
      expect(File.read(@model_file_name)).to eq(expected_file_content)
    end
  end

  let(:options) { AnnotateRb::Options.from({}) }
  let(:model_class_name) { nil }
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

  before do
    @model_dir = Dir.mktmpdir("annotaterb")
    (@model_file_name, _file_content) = write_model("user.rb", starting_file_content)
  end

  context "when annotating a fresh file" do
    context "with magic comments before class declaration with a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # typed: strong

          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # typed: strong

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

      include_examples "annotates the file"
    end

    context "with magic comments before class declaration without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # typed: strong
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # typed: strong
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

      include_examples "annotates the file"
    end

    context "with human comments before class declaration with a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class

          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # some comment about the class

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

      include_examples "annotates the file"
    end

    context "with human comments before class declaration without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # some comment about the class
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

      include_examples "annotates the file"
    end

    context "with magic and human comments before class declaration without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class
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

      include_examples "annotates the file"
    end

    context "with magic and human comments before class declaration with a line break between them" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # some comment about the class
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

      include_examples "annotates the file"
    end

    context "with magic and human comments before class declaration with a line break before class declaration" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class

          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class

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

      include_examples "annotates the file"
    end

    context "with human and magic comments before class declaration without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
          # frozen_string_literal: true
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # some comment about the class
          # frozen_string_literal: true
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

      include_examples "annotates the file"
    end

    context "with human and magic comments before class declaration with a line break between them" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class

          # frozen_string_literal: true
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # some comment about the class

          # frozen_string_literal: true
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

      include_examples "annotates the file"
    end

    context "with human and magic comments before class declaration with a line break before class declaration" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
          # frozen_string_literal: true

          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # some comment about the class
          # frozen_string_literal: true

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

      include_examples "annotates the file"
    end

    context "with `position_in_class: after`" do
      let(:options) { AnnotateRb::Options.new({position_in_class: :after}) }

      context "with magic comments before class declaration with a line break between" do
        let(:starting_file_content) do
          <<~FILE
            # typed: strong

            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # typed: strong

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

        include_examples "annotates the file"
      end

      context "with magic comments before class declaration without a line break between" do
        let(:starting_file_content) do
          <<~FILE
            # typed: strong
            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # typed: strong
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

        include_examples "annotates the file"
      end

      context "with human comments before class declaration with a line break between" do
        let(:starting_file_content) do
          <<~FILE
            # some comment about the class

            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # some comment about the class

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

        include_examples "annotates the file"
      end

      context "with human comments before class declaration without a line break between" do
        let(:starting_file_content) do
          <<~FILE
            # some comment about the class
            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # some comment about the class
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

        include_examples "annotates the file"
      end

      context "with magic and human comments before class declaration without a line break between" do
        let(:starting_file_content) do
          <<~FILE
            # frozen_string_literal: true
            # some comment about the class
            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # frozen_string_literal: true
            # some comment about the class
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

        include_examples "annotates the file"
      end

      context "with magic and human comments before class declaration with a line break between them" do
        let(:starting_file_content) do
          <<~FILE
            # frozen_string_literal: true

            # some comment about the class
            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # frozen_string_literal: true

            # some comment about the class
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

        include_examples "annotates the file"
      end

      context "with magic and human comments before class declaration with a line break before class declaration" do
        let(:starting_file_content) do
          <<~FILE
            # frozen_string_literal: true
            # some comment about the class

            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # frozen_string_literal: true
            # some comment about the class

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

        include_examples "annotates the file"
      end

      context "with human and magic comments before class declaration without a line break between" do
        let(:starting_file_content) do
          <<~FILE
            # some comment about the class
            # frozen_string_literal: true
            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # some comment about the class
            # frozen_string_literal: true
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

        include_examples "annotates the file"
      end

      context "with human and magic comments before class declaration with a line break between them" do
        let(:starting_file_content) do
          <<~FILE
            # some comment about the class

            # frozen_string_literal: true
            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # some comment about the class

            # frozen_string_literal: true
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

        include_examples "annotates the file"
      end

      context "with human and magic comments before class declaration with a line break before class declaration" do
        let(:starting_file_content) do
          <<~FILE
            # some comment about the class
            # frozen_string_literal: true

            class User < ApplicationRecord
            end
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # some comment about the class
            # frozen_string_literal: true

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

        include_examples "annotates the file"
      end

      context "with magic comments before and human comment after class declaration" do
        let(:starting_file_content) do
          <<~FILE
            # frozen_string_literal: true

            class User < ApplicationRecord
            end
            # some comment about the class
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # frozen_string_literal: true

            class User < ApplicationRecord
            end

            # == Schema Information
            #
            # Table name: users
            #
            #  id                     :bigint           not null, primary key
            #
            # some comment about the class
          FILE
        end

        include_examples "annotates the file"
      end

      context "with magic comments before and human comment after class declaration with line break" do
        let(:starting_file_content) do
          <<~FILE
            # frozen_string_literal: true

            class User < ApplicationRecord
            end

            # some comment about the class
          FILE
        end
        let(:expected_file_content) do
          <<~FILE
            # frozen_string_literal: true

            class User < ApplicationRecord
            end

            # == Schema Information
            #
            # Table name: users
            #
            #  id                     :bigint           not null, primary key
            #

            # some comment about the class
          FILE
        end

        include_examples "annotates the file"
      end
    end
  end

  context "when annotating a file with existing annotations with new annotations" do
    let(:schema_info) do
      <<~SCHEMA
        # == Schema Information
        #
        # Table name: users
        #
        #  id                     :bigint           not null, primary key
        #  boolean                :boolean          default(FALSE)
        #
      SCHEMA
    end

    context "with magic comments before annotations with a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # typed: strong

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
          # typed: strong

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with magic comments before annotations without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # typed: strong
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
          # typed: strong
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments before annotations with line a break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class

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
          # some comment about the class

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments before annotations without line a break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
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
          # some comment about the class
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with magic and human comments before annotations without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class
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
          # some comment about the class
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with magic and human comments before annotations with a line break between them" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class

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
          # some comment about the class

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with magic and human comments before annotations with a line break before class declaration" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class

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
          # some comment about the class

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #

          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human and magic comments before annotations without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
          # frozen_string_literal: true
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
          # some comment about the class
          # frozen_string_literal: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human and magic comments before annotations with a line break between them" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class

          # frozen_string_literal: true
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
          # some comment about the class

          # frozen_string_literal: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human and magic comments before annotations with a line break before class declaration" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
          # frozen_string_literal: true

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
          # some comment about the class
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration with a line break" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration with a line break between annotation" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #

          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #

          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration with a line break before class" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # some comment about the class

          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          # some comment about the class

          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration with a line break between and before class" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #

          # some comment about the class

          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #

          # some comment about the class

          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end
  end

  context "when overwriting existing annotations using force: true" do
    let(:options) { AnnotateRb::Options.from({force: true}) }
    let(:schema_info) do
      <<~SCHEMA
        # == Schema Information
        #
        # Table name: users
        #
        #  id                     :bigint           not null, primary key
        #  boolean                :boolean          default(FALSE)
        #
      SCHEMA
    end

    context "with magic comments before annotations with a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # typed: strong

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
          # typed: strong

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with magic comments before annotations without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # typed: strong
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
          # typed: strong
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments before annotations with line a break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class

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
          # some comment about the class

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments before annotations without line a break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
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
          # some comment about the class
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with magic and human comments before annotations without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class
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
          # some comment about the class
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with magic and human comments before annotations with a line break between them" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class

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
          # some comment about the class

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with magic and human comments before annotations with a line break before class declaration" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class

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
          # some comment about the class

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #

          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human and magic comments before annotations without a line break between" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
          # frozen_string_literal: true
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
          # some comment about the class
          # frozen_string_literal: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human and magic comments before annotations with a line break between them" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class

          # frozen_string_literal: true
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
          # some comment about the class

          # frozen_string_literal: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human and magic comments before annotations with a line break before class declaration" do
      let(:starting_file_content) do
        <<~FILE
          # some comment about the class
          # frozen_string_literal: true

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
          # some comment about the class
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration with a line break" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration with a line break between annotation" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #

          # some comment about the class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #

          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration with a line break before class" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # some comment about the class

          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class


          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human comments between annotations and class declaration with a line break between and before class" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #

          # some comment about the class

          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # some comment about the class


          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
          #

          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end
  end

  context "when annotating with position_in_class: before_doc" do
    let(:options) { AnnotateRb::Options.from({position_in_class: "before_doc"}) }

    context "with a class doc directly above the class" do
      let(:starting_file_content) do
        <<~FILE
          # My doc about User
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
          #
          # My doc about User
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with a magic comment and a class doc" do
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # My doc about User
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # My doc about User
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "when re-running on a file already annotated with before_doc" do
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  boolean                :boolean          default(FALSE)
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
          # My doc about User
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
          #  boolean                :boolean          default(FALSE)
          #
          # My doc about User
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "when migrating an existing 'before' annotation to 'before_doc' with --force" do
      let(:options) { AnnotateRb::Options.from({position_in_class: "before_doc", force: true}) }

      let(:starting_file_content) do
        <<~FILE
          # My doc about User
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
          #
          # My doc about User
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end
  end

  context "when annotating a model with inner class declarations and nested_position" do
    let(:options) do
      AnnotateRb::Options.from({nested_position: true, force: true})
    end

    context "with an inner error class declared inside the body" do
      let(:model_class_name) { "User" }

      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true

          module Outer
            module Inner
              class User < ApplicationRecord
                include SomeMixin

                class ProcessingError < StandardError; end

                def call
                  raise ProcessingError
                end
              end
            end
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true

          module Outer
            module Inner
              # == Schema Information
              #
              # Table name: users
              #
              #  id                     :bigint           not null, primary key
              #
              class User < ApplicationRecord
                include SomeMixin

                class ProcessingError < StandardError; end

                def call
                  raise ProcessingError
                end
              end
            end
          end
        FILE
      end

      include_examples "annotates the file"
    end
  end
end
