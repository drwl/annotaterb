# frozen_string_literal: true

# == Schema Information
#
# Table name: collapsed_test_models
#
#  id         :bigint           not null, primary key
#  collapsed  :boolean
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Collapsed
  class TestModel < ApplicationRecord
    def self.table_name_prefix
      "collapsed_"
    end
  end
end
