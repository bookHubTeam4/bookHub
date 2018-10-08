class CreateRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :ratings do |t|
      t.integer :user_id
      t.integer :book_id
      t.float :rating

      t.timestamps
    end
  end
end
