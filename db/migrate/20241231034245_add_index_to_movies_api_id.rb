class AddIndexToMoviesApiId < ActiveRecord::Migration[7.1]
  def change
    add_index :movies, :api_id, unique: true
  end
end
