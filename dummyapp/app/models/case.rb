# == Schema Information
#
# Table name: cases
#
#  id               :integer          not null, primary key
#  default_number   :integer          default(1)
#  default_zero     :integer          default(0)
#  is_default_false :boolean          default(FALSE)
#  is_default_true  :boolean          default(TRUE)
#  json_text_field  :text
#  simple_bool      :boolean
#  simple_int       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Case < ApplicationRecord
  # Model file with fields to test annotations
  serialize :json_text_field, JSON, default: {}
end
