require "application_system_test_case"

class SearchAnalyticsTest < ApplicationSystemTestCase
  setup do
    @ip = "127.0.0.1"
  end

  test "recording search queries" do
    visit root_path
    fill_in "search-box", with: "hello"
    assert_selector "#results", text: "Search recorded"

    fill_in "search-box", with: "hello world"
    assert_selector "#results", text: "Search updated"
  end
end