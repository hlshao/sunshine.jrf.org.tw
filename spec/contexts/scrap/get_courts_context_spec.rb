require 'rails_helper'

RSpec.describe Scrap::GetCourtsContext, :type => :model do

  describe "#perform" do
    context "success" do
      subject{ described_class.new.perform }
      it { expect{ subject }.to change_sidekiq_jobs_size_of(Scrap::ImportCourtContext, :perform) }
    end

    context "notify old data is unexist by scrap" do
      let!(:court) { FactoryGirl.create :court, scrap_name: "xxxxxx" }
      subject{ described_class.new.perform }
      it { expect{ subject }.to change_sidekiq_jobs_size_of(SlackService, :notify) }
    end
  end
end