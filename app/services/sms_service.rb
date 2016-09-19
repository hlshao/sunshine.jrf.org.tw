class SmsService
  attr_accessor :phone

  class << self
    def send_to(phone, text)
      SmsService.new(phone).send_by_twilio(text)
      SmsService.new(phone).send_by_slack(text)
    end

    def send_async(phone, text)
      SmsService.delay.send_to(phone, text)
    end
  end

  def initialize(phone)
    phone = "+886#{phone[1..-1]}" if phone.index("0") == 0
    self.phone = phone
  end

  def send_by_slack(text)
    SlackService.notify_sms_alert_async(text)
  end

  def send_by_twilio(text)
    Twilio::REST::Client.new(Setting.twilio.sid, Setting.twilio.token).account.messages.create(from: Setting.twilio.phone_number,
                                                                                               to:   phone,
                                                                                               body: format_text(text))
  end

  private

  def format_text(text)
    Rails.env.production? ? text : "[#{Rails.env}] #{text}"
  end
end
