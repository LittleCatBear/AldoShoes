# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'em/pure_ruby'
require 'faye/websocket'
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
          # TODO: UpdateStoreInventoryService.call(valid_data) if valid_data.presence
        end
      end
    end

    private

    def validated_data(data)
      # TODO: validate data
      [data['store'], data['model'], data['inventory']]
    end
  end
end

HandleInventoryMessage.run
