require "rails_helper"

RSpec.describe Lawyers::VerdictsController, type: :request do
  before { signin_lawyer }

  describe "#new" do
    subject! { get "/lawyer/score/verdicts/new" }
    it { expect(response).to be_success }
  end

  describe "#rule" do
    subject! { get "/lawyer/score/verdicts/rule" }
    it { expect(response).to be_success }
  end
end
