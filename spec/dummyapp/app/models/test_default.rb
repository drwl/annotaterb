# frozen_string_literal: true

class TestDefault < ApplicationRecord
  self.ignored_columns = ["ignored_column"]
end
