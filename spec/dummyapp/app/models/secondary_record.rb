class SecondaryRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :secondary }
end
