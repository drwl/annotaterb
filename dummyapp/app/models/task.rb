# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  content    :string
#  count      :integer
#  status     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Task < ApplicationRecord
end
