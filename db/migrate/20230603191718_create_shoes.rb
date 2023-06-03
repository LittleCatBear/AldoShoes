class CreateShoes < ActiveRecord::Migration[7.0]
  def change
    create_table :shoes do |t|
      t.string :model
      t.integer :inventory
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
  end
end
