class Scrap::GetSchedulesPagesByStoryTypeContext < BaseContext
  SCHEDULE_INFO_URI = 'http://csdi.judicial.gov.tw/abbs/wkw/WHD3A02.jsp'.freeze
  PAGE_PER = 15

  before_perform :page_total_by_story_type_and_court_code

  class << self
    def perform(court_code, story_type, start_date, end_date)
      new(court_code, story_type, start_date, end_date).perform
    end
  end

  def initialize(court_code, story_type, start_date, end_date)
    @start_date = start_date
    @end_date = end_date
    @start_date_format = "#{@start_date.strftime('%Y').to_i - 1911}#{@start_date.strftime('%m%d')}"
    @end_date_format = "#{@end_date.strftime('%Y').to_i - 1911}#{@end_date.strftime('%m%d')}"
    @court_code = court_code
    @story_type = story_type
    @sleep_time_interval = rand(1..2)
    @crawler_history = CrawlerHistory.find_or_create_by(crawler_on: Time.zone.today)
  end

  def perform
    run_callbacks :perform do
      @page_total.times.each_with_index do |i|
        current_page = i + 1
        Scrap::ParseSchedulesContext.delay(retry: false, queue: 'crawler_schedule').perform(@court_code, @story_type, current_page, @page_total, @start_date_format, @end_date_format)
      end
    end
  end

  private

  def page_total_by_story_type_and_court_code
    @data = { crtid: @court_code, sys: @story_type, date1: @start_date_format, date2: @end_date_format }
    sleep @sleep_time_interval
    response_data = Mechanize.new.post(SCHEDULE_INFO_URI, @data)
    response_data = Nokogiri::HTML(Iconv.new('UTF-8//IGNORE', 'Big5').iconv(response_data.body))
    @page_total = if response_data.css('table')[2].css('tr')[0].text =~ /合計件數/
                    response_data.css('table')[2].css('tr')[0].text.match(/\d+/)[0].to_i / PAGE_PER + 1
                  else
                    0
                  end
  rescue
    request_retry(key: "#{SCHEDULE_INFO_URI} / data=#{@data} / #{Time.zone.today}")
    nil
  end

  def request_retry(key:)
    redis_object = Redis::Counter.new(key, expiration: 1.day)
    if redis_object.value < 12
      self.class.delay_for(1.hour, queue: 'crawler_schedule').perform(@court_code, @story_type, @start_date, @end_date)
      redis_object.incr
    else
      Logs::AddCrawlerError.parse_schedule_data_error(@crawler_history, :crawler_failed, "取得法院代碼-#{@court_code}庭期搜尋頁數失敗, 來源網址:#{SCHEDULE_INFO_URI}, 參數:#{@data}")
    end
  end
end
