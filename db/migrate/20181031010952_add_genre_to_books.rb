class AddGenreToBooks < ActiveRecord::Migration[5.1]
  def change
    add_reference :books, :genre, foreign_key: true
  end
end
