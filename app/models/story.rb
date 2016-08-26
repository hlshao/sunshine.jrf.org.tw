# == Schema Information
#
# Table name: stories
#
#  id               :integer          not null, primary key
#  court_id         :integer
#  main_judge_id    :integer
#  story_type       :string
#  year             :integer
#  word_type        :string
#  number           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  party_names      :text
#  lawyer_names     :text
#  judges_names     :text
#  prosecutor_names :text
#  is_adjudge       :boolean          default(FALSE)
#  adjudge_date     :date
#  pronounce_date   :date
#  is_pronounce     :boolean          default(FALSE)
#

class Story < ActiveRecord::Base
  has_many :schedules
  has_many :verdicts
  has_many :story_relations
  has_many :story_subscriptions, dependent: :destroy
  has_many :verdict_scores
  has_many :schedule_scores
  belongs_to :main_judge, class_name: "Judge", foreign_key: "main_judge_id"
  belongs_to :court

  serialize :party_names, Array
  serialize :lawyer_names, Array
  serialize :judges_names, Array
  serialize :prosecutor_names, Array

  scope :newest, -> { order("id DESC") }

  include Redis::Objects
  counter :lawyer_scored_count
  counter :party_scored_count

  MAX_PARTY_SCORED_COUNT = 3
  MAX_LAWYER_SCORED_COUNT = 5

  def identity
    "#{year}-#{word_type}-#{number}"
  end

  def judgment_verdict
    verdicts.find_by_is_judgment(true)
  end

  def by_relation_judges
    story_relations.where(people_type: "Judge")
  end

  def by_relation_lawyers
    story_relations.where(people_type: "Lawyer")
  end

  def by_relation_parties
    story_relations.where(people_type: "Party")
  end

  def detail_info
    "#{court.full_name}#{year}年#{word_type}字第#{number}號"
  end
end
