class CourtObserver::RegisterCheckContext < BaseContext
  PERMITS = [:name, :email, :password, :password_confirmation].freeze

  before_perform :check_observer_params_exist
  before_perform :check_observer_status
  before_perform :check_agree_policy

  def initialize(params)
    @params = permit_params(params[:court_observer] || params, PERMITS)
    @params[:policy_agreement] = true if params[:policy_agreement] == "1"
  end

  def perform
    run_callbacks :perform do
      true
    end
  end

  private

  def check_agree_policy
    return add_error(:without_policy_agreement, "您尚未勾選同意條款") unless @params[:policy_agreement]
  end

  def check_observer_params_exist
    add_error(:date_blank, "姓名 不可為空白字元") if @params[:name].blank?
    add_error(:date_blank, "email 不可為空白字元") if @params[:email].blank?
    add_error(:date_blank, "密碼 不可為空白字元") if @params[:password].blank?
    add_error(:date_blank, "密碼確認 不可為空白字元") if @params[:password_confirmation].blank?

    return false if errors.present?
  end

  def check_observer_status
    @observer = CourtObserver.find_by_email(@params[:email])
    if @observer && @observer.confirmed?
      return add_error(:observer_exist, "您已經註冊請直接登入")
    elsif @observer
      return add_error(:observer_exist, "此email已經註冊 驗證信已發送到您的信箱 請點擊連結驗證後登入")
    end
  end

end
