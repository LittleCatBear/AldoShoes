# frozen_string_literal: true

class Shoe < ApplicationRecord
  belongs_to :store

  validates :model, presence: true, length: { maximum: 50 }, uniqueness: { scope: :store }
  validates :inventory, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  HIGH_INVENTORY_THRESHOLD = 25
  LOW_INVENTORY_THRESHOLD = 5
end
