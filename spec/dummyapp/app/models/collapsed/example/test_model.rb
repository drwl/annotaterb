# frozen_string_literal: true

module Collapsed
  class TestModel < ApplicationRecord
    def self.table_name_prefix
      "collapsed_"
    end
  end
end
