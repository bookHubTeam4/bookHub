class CreateBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :books do |t|
      t.string :bName
      t.text :bAuthor, array: true, default: []
      t.string :isbn
      t.text :description

      t.timestamps
    end
  end
end
