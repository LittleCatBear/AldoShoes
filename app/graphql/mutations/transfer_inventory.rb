# frozen_string_literal: true

class Mutations::TransferInventory < Mutations::BaseMutation
  argument :to_shoe_id, ID, required: true

  field :shoe, Types::ShoeType, null: true
  field :errors, [String], null: true

  def resolve(to_shoe_id:)
    to_shoe = Shoe.find(to_shoe_id)
    return { errors: ['Shoe not found'] } unless to_shoe

    to_store_id = to_shoe.store.id
    from_shoe = Shoe.where("model = ? and inventory > ? and store_id != ?", to_shoe.model, Shoe::HIGH_INVENTORY_THRESHOLD, to_store_id).first

    if from_shoe.nil?
      { errors: ['No store with enough inventory for a transfer'] }
    else
      transferable_amount = from_shoe.inventory - Shoe::HIGH_INVENTORY_THRESHOLD
      from_shoe.update(inventory: from_shoe.inventory - transferable_amount)
      to_shoe.update(inventory: to_shoe.inventory + transferable_amount)
      ActionCable.server.broadcast(
        'inventory_updates_channel',
        { id: to_shoe.store.id, store: to_shoe.store.name, shoe_id: to_shoe.id, model: to_shoe.model, inventory: to_shoe.inventory }
      )
      ActionCable.server.broadcast(
        'inventory_updates_channel',
        { id: from_shoe.store.id, store: from_shoe.store.name, shoe_id: from_shoe.id, model: from_shoe.model, inventory: from_shoe.inventory }
      )

      { shoe: to_shoe }
    end
  end
end