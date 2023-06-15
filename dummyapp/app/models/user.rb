# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  about      :text
#  age        :integer
#  first_name :string
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
end
