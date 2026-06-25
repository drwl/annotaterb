# frozen_string_literal: true

module Collapsed
  # == Schema Information
  #
  # Table name: collapsed_test_models
  #
  #  id         :integer          not null, primary key
  #  collapsed  :boolean
  #  name       :string
  #  created_at :datetime         not null
  #  updated_at :datetime         not null
  #
  class TestModel < ApplicationRecord
    def self.table_name_prefix
      "collapsed_"
    end
  end
end
