# frozen_string_literal: true

class AddUniquenessConstraintToShoes < ActiveRecord::Migration[7.0]
  def change
    change_table :shoes do |t|
      t.index ['model', 'store_id'], name: 'uniq_model_per_store', unique: true
    end
  end
end
