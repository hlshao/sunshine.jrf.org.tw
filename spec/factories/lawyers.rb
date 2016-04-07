# == Schema Information
#
# Table name: lawyers
#
#  id         :integer          not null, primary key
#  name       :string
#  current    :string
#  avatar     :string
#  gender     :string
#  birth_year :integer
#  memo       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :lawyer do
    name "lawyer"

    trait :with_avatar do
      avatar File.open "#{Rails.root}/spec/fixtures/person_avatar/people-1.jpg"
    end
  end

end
