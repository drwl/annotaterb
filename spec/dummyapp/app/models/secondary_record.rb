class SecondaryRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :secondary } if ENV['MULTI_DB_TEST'] == 'true'
end
