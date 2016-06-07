class Defendant::SendResetPasswordSmsContext < BaseContext
  include Rails.application.routes.url_helpers

  PERMITS = [:identify_number, :phone_number].freeze

  before_perform :find_defendant
  before_perform :generate_reset_password_token
  before_perform :build_message

  def initialize(params)
    @params = permit_params(params[:defendant] || params, PERMITS)
  end

  def perform
    run_callbacks :perform do
      return add_error(:data_update_fail, "未能重設密碼") unless can_reset_password?
      SlackService.fake_defendant_reset_password_notify_async(@message)
      true
      ## SmsService.send_async(@message, @defendant.phone_number)
    end
  end

  private

  def find_defendant
    @defendant = Defendant.find_by(@params)
    return add_error(:data_not_found, "沒有此當事人資訊") unless @defendant
  end

  def generate_reset_password_token
    @token = @defendant.set_reset_password_token
  end

  def can_reset_password?
    @defendant.reset_password_token.present? && @defendant.reset_password_sent_at.present?
  end

  def build_message
    link = edit_defendant_password_url(reset_password_token: @token, host: Setting.host)
    @message = "當事人密碼重設信件 : #{SlackService.render_link(link, "重設密碼網址")}"
  end
end
