# frozen_string_literal: true

require 'test_helper'

class UpdateStoreInventoryTest < ActiveSupport::TestCase
  def setup
    @store = Store.create!(name: 'New Store')
    @shoe = Shoe.create!(store: @store, model: 'Nike 1', inventory: 5)
    @new_inventory = 20
  end

  test 'updates inventory of existing shoe in existing store' do
    result = AldoshoesSchema.execute(
      <<~GRAPHQL,
        mutation {
          updateStoreInventory(input: { store: "#{@store.name}", model: "#{@shoe.model}", inventory: #{@new_inventory} }) {
            store {
              id
              name
            }
            shoe {
              id
              model
              inventory
            }
            errors
          }
        }
      GRAPHQL
    )

    assert_nil result['data']['updateStoreInventory']['errors']
    assert_equal @store.id, result['data']['updateStoreInventory']['store']['id'].to_i
    assert_equal @shoe.id, result['data']['updateStoreInventory']['shoe']['id'].to_i
    assert_equal @new_inventory, result['data']['updateStoreInventory']['shoe']['inventory'].to_i
  end

  test 'creates new store and shoe if they do not exist' do
    result = AldoshoesSchema.execute(
      <<~GRAPHQL,
        mutation {
          updateStoreInventory(input: { store: "Nonexistent Store", model: "Nonexistent Model", inventory: 10 }) {
            store {
              id
              name
            }
            shoe {
              id
              model
              inventory
            }
            errors
          }
        }
      GRAPHQL
    )

    assert_nil result['data']['updateStoreInventory']['errors']
    assert_equal "Nonexistent Store", result['data']['updateStoreInventory']['store']['name']
    assert_equal "Nonexistent Model", result['data']['updateStoreInventory']['shoe']['model']
    assert_equal 10, result['data']['updateStoreInventory']['shoe']['inventory'].to_i
  end

  test 'updates the correct shoe in the correct store' do
    other_store = Store.create!(name: 'Another Store')
    same_model_shoe_in_other_store = Shoe.create!(store: other_store, model: 'Nike 1', inventory: 10)
    new_inventory = 30

    result = AldoshoesSchema.execute(
      <<~GRAPHQL,
        mutation {
          updateStoreInventory(input: { store: "#{@store.name}", model: "#{@shoe.model}", inventory: #{new_inventory} }) {
            store {
              id
              name
            }
            shoe {
              id
              model
              inventory
            }
            errors
          }
        }
      GRAPHQL
    )

    assert_nil result['data']['updateStoreInventory']['errors']
    assert_equal @store.id, result['data']['updateStoreInventory']['store']['id'].to_i
    assert_equal @shoe.id, result['data']['updateStoreInventory']['shoe']['id'].to_i
    assert_equal new_inventory, result['data']['updateStoreInventory']['shoe']['inventory'].to_i
    assert_equal new_inventory, @shoe.reload.inventory

    assert_equal 10, same_model_shoe_in_other_store.reload.inventory
  end

  test 'returns errors when update fails' do
    result = AldoshoesSchema.execute(
      <<~GRAPHQL,
        mutation {
          updateStoreInventory(input: { store: "#{@store.name}", model: "#{@shoe.model}", inventory: -1 }) {
            store {
              id
              name
            }
            shoe {
              id
              model
              inventory
            }
            errors
          }
        }
      GRAPHQL
    )

    assert_includes result['data']['updateStoreInventory']['errors'], "Inventory must be greater than or equal to 0"
  end
end