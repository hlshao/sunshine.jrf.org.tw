require 'rails_helper'

RSpec.describe Scrap::NotifyDailyContext, :type => :model do
  let!(:court) { FactoryGirl.create :court, code: "TPH", scrap_name: "臺灣高等法院" }

  describe "#perform" do
    context "Court" do
      let!(:interval_object) { Redis::Value.new("daily_scrap_court_intervel") }
      let!(:count_object) { Redis::Counter.new("daily_scrap_court_count") }
      before { interval_object.value = "#{ Date.today.to_s } ~ #{ Date.today.to_s }" }
      before { count_object.increment }

      subject{ described_class.new.perform }
      it { expect{ subject }.to change_sidekiq_jobs_size_of(SlackService, :notify) }
    end

    context "Judge" do
      let!(:interval_object) { Redis::Value.new("daily_scrap_judge_intervel") }
      let!(:count_object) { Redis::Counter.new("daily_scrap_judge_count") }
      before { interval_object.value = "#{ Date.today.to_s } ~ #{ Date.today.to_s }" }
      before { count_object.increment }

      subject{ described_class.new.perform }
      it { expect{ subject }.to change_sidekiq_jobs_size_of(SlackService, :notify) }
    end

    context "Verdict" do
      let!(:interval_object) { Redis::Value.new("daily_scrap_verdict_intervel") }
      let!(:count_object) { Redis::Counter.new("daily_scrap_verdict_count") }
      before { interval_object.value = "#{ Date.today.to_s } ~ #{ Date.today.to_s }" }
      before { count_object.increment }

      subject{ described_class.new.perform }
      it { expect{ subject }.to change_sidekiq_jobs_size_of(SlackService, :notify) }
    end

    context "Schedule" do
      let!(:interval_object) { Redis::Value.new("daily_scrap_schedule_intervel") }
      let!(:count_object) { Redis::Counter.new("daily_scrap_schedule_count") }
      before { interval_object.value = "#{ Date.today.to_s } ~ #{ Date.today.to_s }" }
      before { count_object.increment }

      subject{ described_class.new.perform }
      it { expect{ subject }.to change_sidekiq_jobs_size_of(SlackService, :notify) }
    end
  end
end
