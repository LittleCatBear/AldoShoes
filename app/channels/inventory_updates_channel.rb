# typed: true
# frozen_string_literal: true

class InventoryUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "inventory_updates_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    ActionCable.server.broadcast("inventory_updates_channel", data)
  end
end
