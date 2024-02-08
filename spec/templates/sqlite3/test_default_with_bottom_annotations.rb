# frozen_string_literal: true
class TestDefault < ApplicationRecord
end

# == Schema Information
#
# Table name: test_defaults
#
#  id         :integer          not null, primary key
#  boolean    :boolean          default(FALSE)
#  date       :date             default(Tue, 04 Jul 2023)
#  datetime   :datetime         default(Tue, 04 Jul 2023 12:34:56.000000000 UTC +00:00)
#  decimal    :decimal(14, 2)   default(43.21)
#  float      :float            default(12.34)
#  integer    :integer          default(99)
#  string     :string           default("hello world!")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
