# frozen_string_literal: true

# == Schema Information
#
# Table name: test_null_falses
#
#  id         :bigint           not null, primary key
#  binary     :binary(65535)    not null
#  boolean    :boolean          not null
#  date       :date             not null
#  datetime   :datetime         not null
#  decimal    :decimal(14, 2)   not null
#  float      :float            not null
#  integer    :integer          not null
#  string     :string           not null
#  text       :text(65535)      not null
#  timestamp  :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TestNullFalse < ApplicationRecord
end
