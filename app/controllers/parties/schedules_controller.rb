class Parties::SchedulesController < Parties::BaseController
  layout "party"
  include CrudConcern
  before_action :schedule_score, except: [:edit, :update]
  before_action :find_schedule_score, only: [:edit, :update]
  before_action :story_adjudged?, only: [:edit, :update]

  def rule
  end

  def new
  end

  def edit
  end

  def update
    context = Party::ScheduleScoreUpdateContext.new(@schedule_score)
    if context.perform(schedule_score_params)
      @status = "thanks_scored"
      render_as_success(:new)
    else
      context.errors
      render_as_fail(:edit, context.error_messages.join(","))
    end
  end

  def checked_info
    context = Party::CheckScheduleScoreInfoContext.new(current_party)
    if context.perform(schedule_score_params)
      @status = "checked_info"
      render_as_success(:new)
    else
      render_as_fail(:new, context.error_messages.join(","))
    end
  end

  def checked_date
    context = Party::CheckScheduleScoreDateContext.new(current_party)
    context.perform(schedule_score_params)
    if context.has_error?
      @status = "checked_info"
      render_as_fail(:new, context.error_messages.join(","))
    else
      @status = "checked_date"
      render_as_success(:new)
    end
  end

  def checked_judge
    context = Party::CheckScheduleScoreJudgeContext.new(current_party)
    if context.perform(schedule_score_params)
      @status = "checked_judge"
      render_as_success(:new)
    else
      @status = "checked_date"
      render_as_fail(:new, context.error_messages.join(","))
    end
  end

  def create
    context = Party::ScheduleScoreCreateContext.new(current_party)
    if context.perform(schedule_score_params)
      @status = "thanks_scored"
      render_as_success(:new)
    else
      @status = "checked_judge"
      render_as_fail(:new, context.error_messages.join(","))
    end
  end

  private

  def schedule_score_params
    params.fetch(:schedule_score, {}).permit(:id, :court_id, :year, :word_type, :number, :date, :confirmed_realdate, :judge_name, :rating_score, :note, :appeal_judge)
  end

  def schedule_score
    @schedule_score = ScheduleScore.new(schedule_score_params)
  end

  def find_schedule_score
    @schedule_score = current_party.schedule_scores.find(params[:id])
    redirect_as_fail(party_stories_path, "沒有該評鑑紀錄") unless @schedule_score
  end

  def story_adjudged?
    redirect_as_fail(party_stories_path, "案件已判決") if @schedule_score.story.adjudge_date.present?
  end
end
