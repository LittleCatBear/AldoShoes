# frozen_string_literal: true

require 'test_helper'

class StoreInventoryControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get store_inventory_index_url
    assert_response :success
  end
end
