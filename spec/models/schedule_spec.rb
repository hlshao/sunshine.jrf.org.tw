require 'rails_helper'

RSpec.describe Schedule do
  let(:schedule){ FactoryGirl.create :schedule }

  describe "FactoryGirl" do
    context "normalize" do
      subject!{ schedule }
      it { expect(subject).not_to be_new_record }
    end

    context "with main judge" do
      let(:schedule){ FactoryGirl.create :schedule, :with_main_judge }
      subject{ schedule }
      it { expect(subject).not_to be_new_record }
    end
  end
end
