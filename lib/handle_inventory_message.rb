# typed: false
# frozen_string_literal: true

# require 'rubygems'
# require 'bundler/setup'
# require 'em/pure_ruby'
# require 'faye/websocket'
# require 'byebug'
# Bundler.require

# Handle inventory messages coming from InventoryServer
class HandleInventoryMessage
  class << self
    def run
      EM.run do
        ws = Faye::WebSocket::Client.new('ws://Julies-MacBook-Pro.local:8080/')

        ws.on :message do |event|
          data = JSON.parse(event.data)

          uri = URI('http://localhost:3000/graphql')
          req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
          req.body = {
            query: "
              mutation UpdateStoreInventory($store: String!, $model: String!, $inventory: Int!) {
                updateInventory(input: { store: $store, model: $model, inventory: $inventory }) {
                  store {
                    id
                  }
                  errors
                }
              }
            ",
            variables: {
              store: data['store'],
              model: data['model'],
              inventory: data['inventory']
            }
          }.to_json

          Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(req)
          end
        end
      end
    end
  end
end

HandleInventoryMessage.run
