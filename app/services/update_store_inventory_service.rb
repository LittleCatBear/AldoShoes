# typed: strict
# frozen_string_literal: true

# Update shoe store inventory based on message received in HandleInventoryMessage
class UpdateStoreInventoryService
  class << self
    extend T::Sig

    sig { params(data: T::Hash[Symbol, String]).void }
    def call(data)
      store_name = data[:name]
      model = data[:model]
      inventory = data[:inventory].to_i
      return unless store_name && model && inventory

      update_inventory(store_name, model, inventory)
    end

    private

    sig { params(store_name: String, model: String, inventory: Integer).void }
    def update_inventory(store_name, model, inventory)
      ActiveRecord::Base.transaction do
        store = Store.find_or_create_by(name: store_name)
        shoe = Shoe.find_or_create_by(model:, store:)
        shoe.update!(inventory:)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Error saving shoe model #{shoe.model} for store #{store.name}: #{e}")
        raise ActiveRecord::Rollback
      end
    end
  end
end
