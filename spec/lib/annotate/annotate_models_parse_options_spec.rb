# encoding: utf-8
require_relative '../../spec_helper'
require 'annotate/annotate_models'
require 'annotate/active_record_patch'
require 'active_support/core_ext/string'
require 'files'
require 'tmpdir'

RSpec.describe AnnotateModels do
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

  describe '.parse_options' do
    let(:options) do
      {
        root_dir: '/root',
        model_dir: 'app/models,app/one,  app/two   ,,app/three'
      }
    end

    before :each do
      AnnotateModels.send(:parse_options, options)
    end

    describe '@root_dir' do
      subject do
        AnnotateModels.instance_variable_get(:@root_dir)
      end

      it 'sets @root_dir' do
        is_expected.to eq('/root')
      end
    end

    describe '@model_dir' do
      subject do
        AnnotateModels.instance_variable_get(:@model_dir)
      end

      it 'separates option "model_dir" with commas and sets @model_dir as an array of string' do
        is_expected.to eq(['app/models', 'app/one', 'app/two', 'app/three'])
      end
    end
  end
end
