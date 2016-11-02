class LawyerMailer < ApplicationMailer
  def story_before_judge_notice(story_id, lawyer_id)
    @story = Story.find(story_id)
    @lawyer = Lawyer.find(lawyer_id)
    @token = @lawyer.unsubscribe_key
    @open_court_info_wording = MailerPresenters.new.remind_story_before_judge(@story)
    @google_calendar_link = MailerPresenters.new.google_calendar_link(@story)
    @subject = @story.detail_info + '開庭通知'
    mail(to: @lawyer.email, subject: @subject)
  end

  def story_after_judge_notice(story_id, lawyer_id)
    @story = Story.find(story_id)
    @lawyer = Lawyer.find(lawyer_id)
    @token = @lawyer.unsubscribe_key
    @close_court_info_wording = MailerPresenters.new.remind_story_after_judge(@story)
    @subject = @story.detail_info + '開庭完畢，邀請您提供您的寶貴意見！'
    mail(to: @lawyer.email, subject: @subject)
  end
end
