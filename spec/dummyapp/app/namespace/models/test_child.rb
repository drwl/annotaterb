# frozen_string_literal: true

module Namespace
  class TestChild < ApplicationRecord
    def self.table_name_prefix
      "namespace_"
    end
  end
end
