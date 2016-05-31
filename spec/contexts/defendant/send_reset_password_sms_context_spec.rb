require 'rails_helper'

describe Defendant::SendResetPasswordSmsContext do
  let!(:defendant) { FactoryGirl.create :defendant }
  subject { described_class.new(params) }

  context "success" do
    let!(:params){ { identify_number: defendant.identify_number, phone_number: defendant.phone_number } }

    it { expect { subject.perform }.to change_sidekiq_jobs_size_of(SlackService, :notify).by(1) }
    it { expect(subject.perform).to be_truthy }
  end

  context "nil identify_number" do
    let!(:params){ { identify_number: nil, phone_number: defendant.phone_number } }

    it { expect { subject.perform }.not_to change_sidekiq_jobs_size_of(SlackService, :notify) }
    it { expect(subject.perform).to be_falsey }
  end

  context "empty identify_number" do
    let!(:params){ { identify_number: "", phone_number: defendant.phone_number } }

    it { expect(subject.perform).to be_falsey }
  end

  context "nil phone_number" do
    let!(:params){ { identify_number: defendant.identify_number, phone_number: nil } }

    it { expect(subject.perform).to be_falsey }
  end

  context "nil phone_number" do
    let!(:params){ { identify_number: defendant.identify_number, phone_number: "" } }

    it { expect(subject.perform).to be_falsey }
  end

  context "empty input" do
    let!(:params){ { identify_number: "", phone_number: "" } }

    it { expect(subject.perform).to be_falsey }
  end

  context "nil input" do
    let!(:params){ { identify_number: nil, phone_number: nil } }

    it { expect(subject.perform).to be_falsey }
  end
end
