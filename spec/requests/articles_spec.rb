require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  let!(:category) { Category.create!(name: "Test Category") }
  let!(:article) { Article.create!(title: "Test", content: "Test content", category: category) }

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns the article" do
      get :show, params: { id: article.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["title"]).to eq(article.title)
    end
  end

  describe "POST #create" do
    it "creates a new article" do
      expect {
        post :create, params: { article: { title: "New", content: "Body", category_id: category.id } }
      }.to change(Article, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end
end