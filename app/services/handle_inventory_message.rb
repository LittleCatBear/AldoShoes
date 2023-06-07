# typed: false
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
# require 'em/pure_ruby'
# require 'faye/websocket'
require 'byebug'
Bundler.require

# Handle inventory messages coming from InventoryServer
class HandleInventoryMessage
  class << self
    def run
      EM.run do
        ws = Faye::WebSocket::Client.new('ws://Julies-MacBook-Pro.local:8080/')

        ws.on :message do |event|
          data = JSON.parse(event.data)
          valid_data = validated_data(data)

          puts valid_data # rubocop:disable Rails/Output
          byebug
          UpdateStoreInventoryService.call(valid_data) if valid_data.presence
        end
      end
    end

    private

    def validated_data(data)
      store = data['store']
      model = data['model']
      inventory = data['inventory']
      return unless store && model && inventory
      return if inventory.negative?

      { store:, model:, inventory: }
    end
  end
end
