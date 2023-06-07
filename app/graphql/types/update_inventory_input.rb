# frozen_string_literal: true

module Types
  class UpdateInventoryInput < Types::BaseInputObject
    argument :store, String, required: true
    argument :model, String, required: true
    argument :inventory, Integer, required: true
  end
end