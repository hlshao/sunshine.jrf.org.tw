class CourtObserver::CheckScheduleScoreDateContext < BaseContext
  PERMITS = [:court_id, :year, :word_type, :number, :start_on, :story_type, :confirmed_realdate].freeze
  SCORE_INTERVEL = 3.days
  MAX_REPORT_TIME = 5

  before_perform :check_story
  before_perform :check_date
  before_perform :future_date
  before_perform :find_story, unless: :report_realdate?
  before_perform :find_schedule, unless: :report_realdate?
  before_perform :valid_score_intervel
  after_perform :record_report_time, if: :report_realdate?
  after_perform :alert!, if: :report_realdate?

  def initialize(court_observer)
    @court_observer = court_observer
  end

  def perform(params)
    @params = permit_params(params[:schedule_score] || params, PERMITS)
    run_callbacks :perform do
      @schedule
    end
  end

  private

  def check_story
    context = CourtObserver::CheckScheduleScoreInfoContext.new(@court_observer)
    @story = context.perform(@params)
    return add_error(:story_not_found, context.error_messages.join(',')) unless @story
  end

  def check_date
    return add_error(:start_on_blank) unless @params[:start_on].present?
  end

  def future_date
    return add_error(:start_on_invalid) if @params[:start_on].to_date > Time.zone.today
  end

  def find_story
    story_params = @params.except(:start_on, :confirmed_realdate)
    return add_error(:story_not_found) unless @story = Story.where(story_params).last
  end

  def find_schedule
    return add_error(:schedule_not_found) unless @schedule = @story.schedules.on_day(@params[:start_on]).last
  end

  def valid_score_intervel
    range = (@params[:start_on].to_date..@params[:start_on].to_date + SCORE_INTERVEL)
    return add_error(:out_score_intervel) unless range.include?(Time.zone.today)
  end

  def record_report_time
    @court_observer.score_report_schedule_real_date.increment
  end

  def alert!
    if @court_observer.score_report_schedule_real_date.value >= MAX_REPORT_TIME
      SlackService.notify_report_schedule_date_over_range_alert("旁觀者 : #{@court_observer.name} 已超過回報庭期真實開庭日期次數")
    end
  end

  def report_realdate?
    ActiveRecord::Type::Boolean.new.type_cast_from_database(@params[:confirmed_realdate])
  end
end
