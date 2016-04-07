# == Schema Information
#
# Table name: awards
#
#  id          :integer          not null, primary key
#  profile_id  :integer
#  award_type  :string
#  unit        :string
#  content     :text
#  publish_at  :date
#  source      :text
#  source_link :text
#  origin_desc :text
#  memo        :text
#  created_at  :datetime
#  updated_at  :datetime
#  is_hidden   :boolean
#

class AwardsController < BaseController
  def index
    @profile = Profile.find(params[:profile_id])
    if @profile.is_hidden?
      not_found
    end
    @awards = @profile.awards.shown.order_by_publish_at.page(params[:page]).per(12)
    @newest_award = @awards.first
    @newest_punishments = @profile.punishments.shown.order_by_relevant_date.first(3)
    @newest_reviews = @profile.reviews.had_title.shown.order_by_publish_at.first(3)
    set_meta(
      title: "#{@profile.name}的獎勵紀錄",
      description: "#{@profile.name}獎勵相關紀錄清單。",
      keywords: "#{@profile.name}獎勵紀錄,#{@profile.name}",
      image: ActionController::Base.helpers.asset_path('hero-profiles-show-M.png')
    )
  end
end
