class Admin::VerdictsController < Admin::BaseController
  before_action :verdict

  def index
    @search = Verdict.all.newest.ransack(params[:q])
    @verdicts = @search.result.page(params[:page]).per(20)
    @admin_page_title = "判決書列表"
    add_crumb @admin_page_title, "#"
  end

  def download_file
    send_file @verdict.file.path, type: 'text/html; charset=utf-8'
  end

  private

  def verdict
    @verdict ||= params[:id] ? Verdict.find(params[:id]) : Verdict.new
  end
end
