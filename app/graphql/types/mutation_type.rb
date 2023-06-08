# typed: true
# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :updateStoreInventory, mutation: Mutations::UpdateStoreInventory
    field :transferInventory, mutation: Mutations::TransferInventory
  end
end
