# frozen_string_literal: true

require 'integration_spec_helper'

RSpec.describe AnnotateRb::Runner do
  subject(:runner) { described_class.new }
  let(:model_directoy) { 'spec/test_app/app/models'}
  let(:test_default) do
    <<~TEXT
      # frozen_string_literal: true

      class TestDefault < ApplicationRecord
      end
    TEXT
  end
  let(:test_default_annotated) do
    <<~TEXT
      # frozen_string_literal: true

      # == Schema Information
      #
      # Table name: test_defaults
      #
      #  id         :bigint           not null, primary key
      #  boolean    :boolean          default(FALSE)
      #  date       :date             default(Tue, 04 Jul 2023)
      #  datetime   :datetime         default(Tue, 04 Jul 2023 12:34:56.000000000 UTC +00:00)
      #  decimal    :decimal(14, 2)   default(43.21)
      #  float      :float(24)        default(12.34)
      #  integer    :integer          default(99)
      #  string     :string(255)      default("hello world!")
      #  created_at :datetime         not null
      #  updated_at :datetime         not null
      #
      class TestDefault < ApplicationRecord
      end
    TEXT
  end
  let(:test_null_false) do
    <<~TEXT
      # frozen_string_literal: true

      class TestNullFalse < ApplicationRecord
      end
    TEXT
  end
  let(:test_null_false_annotated) do
    <<~TEXT
      # frozen_string_literal: true

      # == Schema Information
      #
      # Table name: test_null_falses
      #
      #  id         :bigint           not null, primary key
      #  binary     :binary(65535)    not null
      #  boolean    :boolean          not null
      #  date       :date             not null
      #  datetime   :datetime         not null
      #  decimal    :decimal(14, 2)   not null
      #  float      :float(24)        not null
      #  integer    :integer          not null
      #  string     :string(255)      not null
      #  text       :text(65535)      not null
      #  timestamp  :datetime         not null
      #  created_at :datetime         not null
      #  updated_at :datetime         not null
      #
      class TestNullFalse < ApplicationRecord
      end
    TEXT
  end

  describe 'Annotating models' do
    it 'annotates model files' do
      test_default_content = File.read("#{model_directoy}/test_default.rb")
      test_null_false_content = File.read("#{model_directoy}/test_null_false.rb")

      expect(test_default_content).to eq(test_default)
      expect(test_null_false_content).to eq(test_null_false)

      runner.run(['models', '--model-dir', model_directoy])

      test_default_annotated_content = File.read("#{model_directoy}/test_default.rb")
      test_null_false_annotated_content = File.read("#{model_directoy}/test_null_false.rb")

      expect(test_default_annotated_content).to eq(test_default_annotated)
      expect(test_null_false_annotated_content).to eq(test_null_false_annotated)
    ensure
      File.write("#{model_directoy}/test_default.rb", test_default)
      File.write("#{model_directoy}/test_null_false.rb", test_null_false)
    end
  end
end
