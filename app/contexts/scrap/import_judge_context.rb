class Scrap::ImportJudgeContext < BaseContext
  before_perform  :parse_import_data
  before_perform  :find_court
  before_perform  :build_judge
  after_perform   :import_branch
  after_perform   :record_import_daily_branch
  after_perform   :record_count_to_daily_notify

  def initialize(data_string)
    @data_string = data_string
    @crawler_history = CrawlerHistory.find_or_create_by(crawler_on: Time.zone.today)
  end

  def perform
    run_callbacks :perform do
      return add_error(:scrap_judge_create_fail) unless @judge.save
      @judge
    end
  end

  private

  def parse_import_data
    @row_data = @data_string.split(',')
    @chamber_name = @row_data[0].strip
    @court_name = @chamber_name =~ /分院/ ? "#{@chamber_name.split('分院')[0]}分院" : "#{@chamber_name.split('法院')[0]}法院"
    @branch_name = @row_data[1].strip
    @memo = @row_data[2][/司法事務官/]
    @judge_name = @row_data[2].squish.delete('法官').delete('司法事務官').delete("\s")
  rescue
    Logs::AddCrawlerError.parse_judge_data_error(@crawler_history, :parse_data_failed, "解析股別法官資料失敗 : 解析資料[ #{@row_data} ]")
    false
  end

  def find_court
    @court = Court.select { |c| c.scrap_name.delete(' ') == @court_name }.last
    return add_error(:scrap_court_not_found) unless @court
  end

  def build_judge
    @judge = Judge.find_by(court: @court, name: @judge_name) || Judge.new(court: @court, name: @judge_name, memo: @memo)
  end

  def import_branch
    @branch = Scrap::ImportBranchContext.new(@judge).perform(@chamber_name, @branch_name)
  end

  def record_import_daily_branch
    Redis::List.new('daily_import_branch_ids') << @branch.id
  end

  def record_count_to_daily_notify
    Redis::Counter.new('daily_scrap_judge_count').increment
  end
end
