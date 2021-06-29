require 'test_helper'

class QuizsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get quizs_new_url
    assert_response :success
  end

end
