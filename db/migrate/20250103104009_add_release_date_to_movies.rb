class AddReleaseDateToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :release_date, :integer
  end
end
