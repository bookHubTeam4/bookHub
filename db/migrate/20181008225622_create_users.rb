class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :firstName
      t.string :lastName
      t.string :address
      t.string :imageUrl

      t.timestamps
    end
  end
end
