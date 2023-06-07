# typed: true
# frozen_string_literal: true

class InventoryUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "inventory_update_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
