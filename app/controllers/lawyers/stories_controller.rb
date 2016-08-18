class Lawyers::StoriesController < Lawyers::BaseController
  layout "lawyer"
  before_action :find_story, only: [:show]
  before_action :has_score?, only: [:show]

  def index
    @stories = ::LawyerQueries.new(current_lawyer).get_stories
  end

  def show
    @pending_score_verdict = ::LawyerQueries.new(current_lawyer).pending_score_verdict(@story)
    @pending_score_schedules = ::LawyerQueries.new(current_lawyer).pending_score_schedules(@story)
  end

  private

  def find_story
    # TODO: security issue
    @story = begin
               Story.find(params[:id])
             rescue
               nil
             end
    redirect_as_fail(lawyer_root_path, "找不到該案件") unless @story
  end

  def has_score?
    @scores_sorted = ::LawyerQueries.new(current_lawyer).get_scores_json(@story, sort_by: "date")
    redirect_as_fail(party_stories_path, "尚未有評鑑紀錄") unless @scores_sorted.present?
  end
end
