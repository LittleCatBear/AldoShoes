# typed: strict
# frozen_string_literal: true

require 'test_helper'

# Unit tests file for UpdateStoreInventoryService
class UpdateStoreInventoryServiceTest < ActiveSupport::TestCase
  test '.call creates a new store if one does not exist for the provided name' do
    message = { name: 'New store', model: 'New model', inventory: 1 }

    assert_equal 0, Store.count

    assert_difference -> { Store.count }, 1 do
      UpdateStoreInventoryService.call(message)
    end
  end

  test '.call creates a new shoe model for a store' do
    store = Store.create!(name: 'New store')
    message = { name: 'New store', model: 'New model', inventory: 1 }

    assert_not Shoe.find_by(model: 'New model')

    UpdateStoreInventoryService.call(message)
    shoe = store.shoes.first
    assert 'New model', shoe.model
    assert 1, shoe.inventory
  end

  test '.call does not create a new shoe model for a store if it already exists, updates the inventory' do
    store = Store.create!(name: 'New store')
    Shoe.create!(model: 'New model', inventory: 3, store:)
    message = { name: 'New store', model: 'New model', inventory: 14 }

    assert_no_difference -> { Shoe.count } do
      UpdateStoreInventoryService.call(message)

      shoe = store.shoes.first
      assert 'New model', shoe.model
      assert 14, shoe.inventory
    end
  end

  test '.call adds a new shoe model to the correct store' do
    store = Store.create!(name: 'New store')
    store2 = Store.create!(name: 'Another store')
    assert_empty store.shoes
    assert_empty store2.shoes

    message = { name: 'New store', model: 'New model', inventory: 13 }
    UpdateStoreInventoryService.call(message)

    assert_empty store2.reload.shoes
    shoe = store.reload.shoes.first
    assert 'New model', shoe.model
    assert 13, shoe.inventory
  end

  test '.call logs an error message if a shoe record failed to save' do
    message = { name: 'New store', model: 'New model', inventory: -4 }

    assert_no_difference -> { Shoe.count } do
      with_logger do |output|
        UpdateStoreInventoryService.call(message)
        assert_match(
          /Error saving shoe model New model for store New store: Validation failed: Inventory must be greater than or equal to 0/,
          output.string
        )
      end
    end
  end

  test '.call does not persist a new store if a shoe record failed to save' do
    message = { name: 'New store', model: 'New model', inventory: -4 }

    assert_no_difference -> { Store.count } do
      UpdateStoreInventoryService.call(message)
    end
  end
end
