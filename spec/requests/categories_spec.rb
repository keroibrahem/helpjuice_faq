require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let!(:category) { Category.create!(name: "Test Category") }

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    it "creates a new category" do
      expect {
        post :create, params: { category: { name: "Another" } }
      }.to change(Category, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end
end