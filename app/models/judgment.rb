# == Schema Information
#
# Table name: judgments
#
#  id                 :integer          not null, primary key
#  court_id           :integer
#  main_judge_id      :integer
#  presiding_judge_id :integer
#  judge_no           :string(255)
#  court_no           :string(255)
#  judge_type         :string(255)
#  judge_date         :date
#  reason             :text
#  content            :text
#  comment            :text
#  source             :string(255)
#  source_link        :string(255)
#  memo               :text
#  created_at         :datetime
#  updated_at         :datetime
#

class Judgment < ActiveRecord::Base
  belongs_to :court
  belongs_to :main_judge, :class_name => "Profile", :foreign_key => :main_judge_id
  belongs_to :presiding_judge, :class_name => "Profile", :foreign_key => :presiding_judge_id
end
