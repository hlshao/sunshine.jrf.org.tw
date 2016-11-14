require 'rails_helper'

describe Party::ScheduleScoreUpdateContext do
  let!(:party) { create :party }
  let!(:schedule_score) { create :schedule_score, schedule_rater: party }
  let(:context) { described_class.new(schedule_score) }

  describe 'perform' do
    context 'rating score empty' do
      let!(:params) { { score_1_1: '', note: 'xxx', appeal_judge: false } }
      subject { context.perform(params) }

      it { expect(subject).to be_falsey }
    end

    context 'success' do
      let!(:params) { { score_1_1: 5, score_1_2: 5, score_1_3: 5, note: 'xxx', appeal_judge: false } }
      subject { context.perform(params) }

      it { expect(subject).to be_truthy }
      it { expect { subject }.to change { schedule_score.reload.note } }
    end
  end
end
