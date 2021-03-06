class Scrap::ParseSchedulesContext < BaseContext
  SCHEDULE_INFO_URI = 'http://csdi.judicial.gov.tw/abbs/wkw/WHD3A02.jsp'.freeze

  before_perform :scrap_schedule
  before_perform :parse_schedule_info

  class << self
    def perform(court_code, story_type, current_page, page_total, start_date_format, end_date_format)
      new(court_code, story_type, current_page, page_total, start_date_format, end_date_format).perform
    end
  end

  def initialize(court_code, story_type, current_page, page_total, start_date_format, end_date_format)
    @court_code = court_code
    @story_type = story_type
    @current_page = current_page
    @page_total = page_total
    @start_date_format = start_date_format
    @end_date_format = end_date_format
    @sleep_time_interval = rand(1..2)
    @crawler_history = CrawlerHistory.find_or_create_by(crawler_on: Time.zone.today)
  end

  def perform
    run_callbacks :perform do
      @hash_array.each do |hash|
        Scrap::ImportScheduleContext.delay(retry: false).perform(@court_code, hash)
      end
    end
  end

  private

  def scrap_schedule
    @params = "?pageNow=#{@current_page}&pageTotal=#{@page_total}&pageSize=15&rowStart=1&crtid=#{@court_code}&sys=#{@story_type}&date1=#{@start_date_format}&date2=#{@end_date_format}&dptcd=&crmyy=&crmid=&crmno="
    sleep @sleep_time_interval
    response_data = Mechanize.new.get(SCHEDULE_INFO_URI + @params)
    @data = Nokogiri::HTML(Iconv.new('UTF-8//IGNORE', 'Big5').iconv(response_data.body))
  rescue
    request_retry(key: "#{SCHEDULE_INFO_URI} / params=#{@params} / #{Time.zone.today}")
  end

  def parse_schedule_info
    @hash_array = []
    scope = @data.css('table')[1].css('tr')
    scope.length.times.each do |index|
      # first row is table desc
      next if index == 0
      row_data = scope[index].css('td')
      hash = {
        story_type: row_data[1].text.strip,
        year: row_data[2].text.strip.to_i,
        word_type: row_data[3].text.strip,
        number: row_data[4].text.squish,
        start_at: convert_scrap_time(row_data[5].text.strip, row_data[6].text.strip),
        start_on: convert_scrap_time(row_data[5].text.strip, row_data[6].text.strip).to_date,
        courtroom: row_data[7].text.strip,
        branch_name: row_data[8].text.strip,
        is_pronounced: row_data[9].text.strip.match('宣判').present?
      }
      @hash_array << hash
    end
  end

  def convert_scrap_time(date_string, time_string)
    split_date = date_string.split('/').map(&:to_i)
    year = split_date[0] + 1911

    hours = (time_string[0] + time_string[1]).to_i
    minutes = (time_string[2] + time_string[3]).to_i
    DateTime.new(year, split_date[1], split_date[2], hours, minutes, 0, '+8')
  end

  def request_retry(key:)
    redis_object = Redis::Counter.new(key, expiration: 1.day)
    if redis_object.value < 12
      self.class.delay_for(1.hour).perform(@court_code, @story_type, @current_page, @page_total, @start_date_format, @end_date_format)
      redis_object.incr
    else
      Logs::AddCrawlerError.parse_schedule_data_error(@crawler_history, :crawler_failed, "取得法院代碼-#{@court_code}庭期單頁資料失敗, 來源網址:#{SCHEDULE_INFO_URI}, 參數:#{@params}")
    end
    false
  end
end
