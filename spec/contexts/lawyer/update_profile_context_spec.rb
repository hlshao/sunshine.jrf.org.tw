require 'rails_helper'

describe Lawyer::UpdateProfileContext do
  let!(:lawyer) { FactoryGirl.create :lawyer }
  let!(:context) { described_class.new(lawyer) }
  context "success" do

    let!(:params){ { phone_number: "0911111111" } }
    subject { described_class.new(lawyer).perform(params) }

    it { expect(subject).to be_truthy }
    it { expect { subject }.to change { lawyer.reload.current } }
  end
end
