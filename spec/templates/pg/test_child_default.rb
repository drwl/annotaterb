# == Schema Information
#
# Table name: test_child_defaults
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  test_default_id :bigint           not null
#
# Indexes
#
#  index_test_child_defaults_on_test_default_id  (test_default_id)
#
# Foreign Keys
#
#  fk_rails_...  (test_default_id => test_defaults.id)
#
class TestChildDefault < ApplicationRecord
  belongs_to :test_default
end
