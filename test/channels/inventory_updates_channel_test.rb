# frozen_string_literal: true

require 'test_helper'

class InventoryUpdatesChannelTest < ActionCable::Channel::TestCase
  test "subscribes" do
    subscribe
    assert subscription.confirmed?
  end
end
