class Scrap::ImportVerdictContext < BaseContext
  before_perform :parse_orginal_data
  before_perform :parse_nokogiri_data
  before_perform :parse_verdict_word
  before_perform :parse_verdict_content
  before_perform :build_analysis_context
  before_perform :find_main_judge
  before_perform :find_or_create_story
  before_perform :build_verdict
  after_perform  :upload_file
  after_perform  :update_data_to_story
  after_perform  :update_adjudge_date

  def initialize(import_data, court)
    @import_data = import_data
    @court = court
  end

  def perform
    run_callbacks :perform do
      add_error("create date fail") unless @verdict.save
      @verdict
    end
  end

  private

  def parse_orginal_data
    @orginal_data = @import_data.body.force_encoding("UTF-8")
  rescue => e
    SlackService.scrap_notify_async("判決書分析資料失敗: parse_orginal_data處理資料為空\n import_data : #{@import_data}\n #{e.message}")
  end

  def parse_nokogiri_data
    @nokogiri_data = Nokogiri::HTML(@import_data.body)
  rescue => e
    SlackService.scrap_notify_async("判決書分析資料失敗: parse_nokogiri_data處理資料為空\n import_data : #{@import_data}\n #{e.message}")
  end

  def parse_verdict_word
    @verdict_word = @nokogiri_data.css("table")[4].css("tr")[0].css("td")[1].text
  rescue => e
    SlackService.scrap_notify_async("判決書分析資料失敗: parse_verdict_word處理資料為空\n nokogiri_data : #{@nokogiri_data}\n #{e.message}")
  end

  def parse_verdict_content
    @verdict_content = @nokogiri_data.css("pre").text
  rescue => e
    SlackService.scrap_notify_async("判決書分析資料失敗: parse_verdict_content處理資料為空\n nokogiri_data : #{@nokogiri_data}\n #{e.message}")
  end

  def build_analysis_context
    @analysis_context = Scrap::AnalysisVerdictContext.new(@verdict_content, @verdict_word)
  end

  def find_main_judge
    @main_judge = Judge.find_by(name: @analysis_context.main_judge_name)
  end

  def find_or_create_story
    array = @verdict_word.split(",")
    @story = Story.find_or_create_by(year: array[0], word_type: array[1], number: array[2], court: @court)
  end

  def build_verdict
    @verdict = Verdict.new(
      story: @story,
      is_judgment: @analysis_context.is_judgment?,
      judges_names: @analysis_context.judges_names,
      prosecutor_names: @analysis_context.prosecutor_names,
      lawyer_names: @analysis_context.lawyer_names,
      defendant_names: @analysis_context.defendant_names
    )
  end

  def upload_file
    Scrap::UploadVerdictContext.new(@orginal_data).perform(@verdict)
  end

  def update_data_to_story
    @story.assign_attributes(judges_names: (@story.judges_names + @verdict.judges_names).uniq)
    @story.assign_attributes(prosecutor_names: (@story.prosecutor_names + @verdict.prosecutor_names).uniq)
    @story.assign_attributes(lawyer_names: (@story.lawyer_names + @verdict.lawyer_names).uniq)
    @story.assign_attributes(defendant_names: (@story.defendant_names + @verdict.defendant_names).uniq)
    @story.assign_attributes(main_judge: @main_judge) if @main_judge
    @story.assign_attributes(is_adjudge: @verdict.is_judgment?) if @verdict.is_judgment? && !@story.is_adjudge
    @story.save
  end

  def update_adjudge_date
    return unless @analysis_context.is_judgment?
    @story.update_attributes(adjudge_date: Date.today) unless @story.adjudge_date
    @verdict.update_attributes(adjudge_date: Date.today)
  end
end
