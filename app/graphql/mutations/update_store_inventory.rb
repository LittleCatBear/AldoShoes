# typed: strict
# frozen_string_literal: true

class UpdateStoreInventory < BaseMutation
  argument :input, Types::UpdateInventoryInput, required: true

  field :store, Types::StoreType, null: false
  field :errors, [String], null: true

  def resolve(input:)
    store = Store.find_or_create_by(name: input.store)
    shoe = Shoe.find_or_create_by(model: input.model)
    inventory = Inventory.find_or_create_by(store: store, shoe: shoe)

    if inventory.update(quantity: input.inventory)
      { store: store }
    else
      { errors: inventory.errors.full_messages }
    end
  end
end