# == Schema Information
#
# Table name: schedules
#
#  id          :integer          not null, primary key
#  story_id    :integer
#  court_id    :integer
#  branch_name :string
#  date        :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :schedule do
    branch_name "股別名稱"
    date { Date.current }
    court { FactoryGirl.create :court }
    story { FactoryGirl.create :story }
  end

end