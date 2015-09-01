require 'rails_helper'

RSpec.describe Admin::ArticlesController do
  let!(:profile){ FactoryGirl.create :profile }

  before{ signin_user }

  describe "already had a article" do
    let!(:article){ FactoryGirl.create :article, profile: profile }

    it "GET /admin/profiles/profile.id/articles" do
      get "/admin/profiles/#{profile.id}/articles"
      expect(response).to be_success
    end

    it "GET /admin/profiles/profile.id/articles/new" do
      get "/admin/profiles/#{profile.id}/articles/new"
      expect(response).to be_success
    end

    it "GET /admin/profiles/profile.id/articles/123/edit" do
      get "/admin/profiles/#{profile.id}/articles/#{article.id}/edit"
      expect(response).to be_success
    end

    it "PUT /admin/profiles/profile.id/articles/123" do
      expect{
        put "/admin/profiles/#{profile.id}/articles/#{article.id}", admin_article: { article_type: "haha" }
      }.to change{ article.reload.article_type }.to("haha")
      expect(response).to be_redirect
    end

    it "DELETE /admin/profiles/profile.id/articles/123" do
      delete "/admin/profiles/#{profile.id}/articles/#{article.id}"
      expect(Article.count).to be_zero
    end
  end

  it "POST /admin/profiles/profile.id/articles" do
    expect{
      post "/admin/profiles/#{profile.id}/articles", admin_article: FactoryGirl.attributes_for(:article)
    }.to change{ Article.count }.by(1)
    expect(response).to be_redirect
  end
end