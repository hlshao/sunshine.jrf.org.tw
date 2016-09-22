require "rails_helper"

RSpec.describe Lawyers::EmailsController, type: :request do
  before { signin_lawyer }

  describe "#edit" do
    subject! { get "/lawyer/email/edit" }

    it { expect(response).to be_success }
  end

  describe "#update" do
    context "success" do
      subject! { put "/lawyer/email", lawyer: { email: "test@gmail.com", current_password: "123123123" } }

      it { expect(response).to redirect_to("/lawyer/profile") }
    end

    context "wrong password" do
      subject! { put "/lawyer/email", lawyer: { email: "test@gmail.com", current_password: "" } }

      it { expect(current_lawyer.email).not_to eq("test@gmail.com") }
      it { expect(response).to be_success }
      it { expect(response.body).to match("test@gmail.com") }
      it { expect(response.body).not_to match("目前等待驗證中信箱") }
    end
  end
end
