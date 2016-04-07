# == Schema Information
#
# Table name: schedules
#
#  id          :integer          not null, primary key
#  story_id    :integer
#  court_id    :integer
#  branch_name :integer
#  date        :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Schedule < ActiveRecord::Base
end
