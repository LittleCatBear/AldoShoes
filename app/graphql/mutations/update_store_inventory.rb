# typed: strict
# frozen_string_literal: true

class Mutations::UpdateStoreInventory < Mutations::BaseMutation
  argument :store, String, required: true
  argument :model, String, required: true
  argument :inventory, Integer, required: true

  field :store, Types::StoreType, null: true
  field :shoe, Types::ShoeType, null: true
  field :errors, [String], null: true

  def resolve(store:, model:, inventory:)
    shoe_store = Store.find_or_create_by(name: store)
    shoe = Shoe.find_or_create_by(model:, store: shoe_store)

    if shoe.update(inventory: inventory)
      ActionCable.server.broadcast(
        'inventory_updates_channel',
        { id: shoe_store.id, store: shoe_store.name, model: shoe.model, shoe_id: shoe.id, inventory: shoe.inventory }
      )
      { store: shoe_store, shoe: shoe }
    else
      { errors: shoe.errors.full_messages }
    end
  end
end