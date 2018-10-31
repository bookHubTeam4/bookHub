class AddNyTimesListToBooks < ActiveRecord::Migration[5.1]
  def change

    add_column :books, :ny_times_list, :string
  end
end
