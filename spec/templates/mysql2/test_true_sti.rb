# frozen_string_literal: true

# == Schema Information
#
# Table name: test_parents
#
#  id         :bigint           not null, primary key
#  something  :string(255)
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TestTrueSti < TestParent
end
