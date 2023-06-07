# frozen_string_literal: true

module Types
  class ShoeType < Types::BaseObject
    field :id, ID, null: false
    field :model, String, null: false
    field :inventory, Integer, null: false
  end
end