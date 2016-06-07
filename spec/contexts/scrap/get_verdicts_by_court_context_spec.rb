require 'rails_helper'

RSpec.describe Scrap::GetVerdictsByCourtContext, :type => :model do
  let!(:court) { FactoryGirl.create :court, code: "TPH" }
  let!(:start_date) { Date.today }
  let!(:end_date) { Date.today }

  describe "#perform" do
    subject{ described_class.new(court, start_date, end_date).perform }

    it { expect{ subject }.to change_sidekiq_jobs_size_of(Scrap::GetVerdictsTotalResultByStoryTypeContext, :perform) }
  end
end