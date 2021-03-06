require 'rails_helper'

RSpec.describe Search::SchedulesController, type: :request do
  include_context 'create_data_for_request'
  let!(:schedule) { create :schedule, story: story, court: court }

  describe '#index' do
    context 'success' do
      let(:url) { URI.encode("/search/#{code}/#{story.identity}/schedules") }
      before { get url }
      it { expect(response.body).to match(story.identity) }
    end

    context 'story not exist' do
      let(:url) { URI.encode("/search/#{code}/#{story.identity + '1'}/schedules") }
      before { get url }
      it { expect(response).to redirect_to('/search') }
      it { expect(flash[:error]).to eq('案件不存在') }
    end

    context 'schedule not exist' do
      before { Schedule.destroy_all }
      let(:url) { URI.encode("/search/#{code}/#{story.identity}/schedules") }
      before { get url }
      it { expect(response.body).to match('共 0 筆') }
    end
  end
end
