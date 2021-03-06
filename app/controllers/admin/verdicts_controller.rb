class Admin::VerdictsController < Admin::BaseController
  before_action :verdict
  before_action(except: [:index]) { add_crumb('判決列表', admin_verdicts_path) }

  def index
    @search = Verdict.includes(story: :court).newest.ransack(params[:q])
    @verdicts = @search.result.includes(:story).page(params[:page]).per(20)
    @admin_page_title = '判決列表'
    add_crumb @admin_page_title, '#'
  end

  def show
    @admin_page_title = "#{@verdict.story.court.name}-#{@verdict.story.identity} - 判決"
    add_crumb @admin_page_title, '#'
  end

  def download_file
    @file_url = Rails.env.development? || Rails.env.test? ? @verdict.file.path : @verdict.file.url.gsub('//', 'http://')
    data = open(@file_url).read
    send_data data, disposition: 'attachment', filename: "verdict-#{@verdict.id}.html"
  end

  private

  def verdict
    @verdict ||= params[:id] ? Verdict.find(params[:id]) : Verdict.new
  end
end
