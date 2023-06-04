# frozen_string_literal: true

require 'test_helper'

# Unit tests file for Shoe model
class ShoeTest < ActiveSupport::TestCase
  test 'valid? returns true if the shoe has valid attributes' do
    shoe = Shoe.new(
      model: 'Model1',
      inventory: 3,
      store: Store.create!(name: 'test store')
    )

    assert shoe.valid?
  end

  test 'valid? returns false if the model name is too long' do
    shoe = Shoe.new(
      model: 'a' * 51,
      inventory: 3,
      store: Store.create!(name: 'test store')
    )
    assert_not shoe.valid?
  end

  test 'valid? returns false if the inventory is negative' do
    shoe = Shoe.new(
      model: 'Model1',
      inventory: -3,
      store: Store.create!(name: 'test store')
    )
    assert_not shoe.valid?
  end

  test 'valid? returns true for the same model in 2 different stores' do
    Shoe.create!(model: 'Model1', inventory: 3, store: Store.create!(name: 'test store'))

    shoe2 = Shoe.new(
      model: 'Model1',
      inventory: 3,
      store: Store.create!(name: 'test store')
    )
    assert shoe2.valid?
  end

  test 'valid? returns false for a duplicated model in the same stores' do
    store = Store.create!(name: 'test store')
    Shoe.create!(model: 'Model1', inventory: 3, store:)

    shoe2 = Shoe.new(
      model: 'Model1',
      inventory: 3,
      store:
    )
    assert_not shoe2.valid?
  end
end
