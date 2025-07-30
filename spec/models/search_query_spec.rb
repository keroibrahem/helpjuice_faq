require 'rails_helper'

RSpec.describe SearchQueriesController, type: :controller do
  let(:valid_ip) { '192.168.1.1' }

  before do
    request.env['REMOTE_ADDR'] = valid_ip
  end

  describe "POST #create" do
    context "with valid search progression" do
      it "stores only final complete search" do
        post :create, params: { query: "what" }
        expect(response).to have_http_status(:ok)
        
        post :create, params: { query: "what is" }
        post :create, params: { query: "what is a" }
        post :create, params: { query: "what is a car" }
        
        expect(SearchQuery.count).to eq(1)
        expect(SearchQuery.last.query).to eq("what is a car")
      end
    end

    context "with rate limiting" do
      it "blocks after 30 requests" do
        30.times { post :create, params: { query: "test" } }
        expect(response).to have_http_status(:ok)
        
        post :create, params: { query: "test" }
        expect(response).to have_http_status(:too_many_requests)
      end
    end
  end

  describe "GET #analytics" do
    it "returns search analytics" do
      SearchQuery.create!(query: "ruby", ip_address: valid_ip)
      SearchQuery.create!(query: "rails", ip_address: valid_ip)
      
      get :analytics
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['searches']).to include("ruby" => 1, "rails" => 1)
    end
  end
end