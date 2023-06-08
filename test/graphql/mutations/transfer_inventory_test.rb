require 'test_helper'

class TransferInventoryTest < ActiveSupport::TestCase
  def setup
    @high_inventory_shoe = Shoe.create!(store: Store.create(name: 'New store 1'), model: 'Nike 1', inventory: 29)
    @low_inventory_shoe = Shoe.create!(store: Store.create(name: 'New store 2'), model: 'Nike 1', inventory: 2)
    @transfer_quantity = @high_inventory_shoe.inventory - Shoe::HIGH_INVENTORY_THRESHOLD
  end

  test 'transfers inventory to the shoe with low inventory' do
    new_quantity_for_low_inventory = @transfer_quantity + @low_inventory_shoe.inventory
    new_quantity_for_high_inventory = @high_inventory_shoe.inventory - @transfer_quantity

    result = AldoshoesSchema.execute(
      <<~GRAPHQL,
        mutation {
          transferInventory(input: { toShoeId: #{@low_inventory_shoe.id} }) {
            shoe {
              id
              inventory
            }
            errors
          }
        }
      GRAPHQL
    )

    assert_nil result['data']['transferInventory']['errors']
    assert_equal @low_inventory_shoe.id, result['data']['transferInventory']['shoe']['id'].to_i
    assert_equal new_quantity_for_low_inventory, result['data']['transferInventory']['shoe']['inventory'].to_i
    assert_equal 6, @low_inventory_shoe.reload.inventory
    assert_equal Shoe::HIGH_INVENTORY_THRESHOLD, @high_inventory_shoe.reload.inventory
  end

  test 'returns an error when there is no shoe with high inventory' do
    @high_inventory_shoe.update(inventory: 5)

    result = AldoshoesSchema.execute(
      <<~GRAPHQL,
        mutation {
          transferInventory(input: { toShoeId: #{@low_inventory_shoe.id} }) {
            shoe {
              id
              inventory
            }
            errors
          }
        }
      GRAPHQL
    )

    assert_nil result['data']['transferInventory']['shoe']
    assert_includes result['data']['transferInventory']['errors'], 'No store with enough inventory for a transfer'
  end
end
