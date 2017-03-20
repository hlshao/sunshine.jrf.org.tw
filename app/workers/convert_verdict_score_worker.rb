class ConvertVerdictScoreWorker
  include Concerns::ScoreInterval
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options retry: 3

  recurrence backfill: true do
    daily.hour_of_day(3)
  end

  def perform
    find_stories.each do |story|
      Story::CalculateVerdictScoresContext.delay.perform(story)
    end
  end

  private

  def find_stories
    Story.not_caculate.where('pronounce_date < ?', Time.zone.today - VERDICT_INTERVAL)
  end
end
