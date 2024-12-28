class AddApiIdToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :api_id, :string
  end
end
