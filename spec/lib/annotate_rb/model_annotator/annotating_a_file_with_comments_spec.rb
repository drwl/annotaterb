# frozen_string_literal: true

RSpec.describe "Annotating a file with comments" do
  include AnnotateTestHelpers
  include AnnotateTestConstants

  shared_examples "annotates the file" do
    it "writes the expected annotations to the file" do
      AnnotateRb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
      expect(File.read(@model_file_name)).to eq(expected_file_content)
    end
  end

  let(:options) { AnnotateRb::Options.new({}) }
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

      include_examples "annotates the file"
    end

    context "with magic and human comments before class declaration with a line break before class declaration", skip: "To be fixed" do
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

    context "with human and magic comments before class declaration without a line break between", skip: "To be fixed" do
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

    context "with human and magic comments before class declaration with a line break between them", skip: "To be fixed" do
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

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #

          # frozen_string_literal: true
          class User < ApplicationRecord
          end
        FILE
      end

      include_examples "annotates the file"
    end

    context "with human and magic comments before class declaration with a line break before class declaration", skip: "To be fixed" do
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

      context "with human and magic comments before class declaration without a line break between", skip: "To fix" do
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

      context "with human and magic comments before class declaration with a line break between them", skip: "To fix" do
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
            # some comment about the class

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

            # some comment about the class

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

    context "with human comments between annotations and class declaration", skip: "It strips the human comment, to be fixed" do
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

    context "with human comments between annotations and class declaration with a line break", skip: "It strips the human comment, to be fixed" do
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

    context "with human comments between annotations and class declaration with a line break before class", skip: "It strips the human comment, to be fixed" do
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
    let(:options) { AnnotateRb::Options.new({force: true}) }
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

    context "with human comments before annotations with line a break between", skip: "To fix" do
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

    context "with human comments before annotations without line a break between", skip: "To fix" do
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

    context "with magic and human comments before annotations without a line break between", skip: "To fix" do
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

    context "with magic and human comments before annotations with a line break between them", skip: "To fix" do
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

    context "with magic and human comments before annotations with a line break before class declaration", skip: "To fix" do
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

    context "with human and magic comments before annotations without a line break between", skip: "To fix" do
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

    context "with human and magic comments before annotations with a line break between them", skip: "To fix" do
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

    context "with human and magic comments before annotations with a line break before class declaration", skip: "To fix" do
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

    context "with human comments between annotations and class declaration", skip: "To fix" do
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

    context "with human comments between annotations and class declaration with a line break", skip: "To fix" do
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

    context "with human comments between annotations and class declaration with a line break between annotation", skip: "To fix" do
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

    context "with human comments between annotations and class declaration with a line break before class", skip: "To fix" do
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

    context "with human comments between annotations and class declaration with a line break between and before class", skip: "To fix" do
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
end
