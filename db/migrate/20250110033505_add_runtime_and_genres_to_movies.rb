class AddRuntimeAndGenresToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :runtime, :integer
    add_column :movies, :genres, :string, array: true, default: []
  end
end
