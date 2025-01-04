class BookmarksController < ApplicationController
  # def new
  #   @list = List.find(params[:list_id])
  #   @bookmark = Bookmark.new
  # end

  def create
    @list = List.find(params[:list_id])
    # @bookmark = Bookmark.new(bookmark_params)
    # @bookmark.list = @list

    movie_ids = params[:movie_ids].is_a?(Array) ? [params[:movie_ids]] : params[:movie_ids].to_s.split(',')

    new_bookmarks = []

    movie_ids.each do |movie_id|
      movie = Movie.find_by(api_id: movie_id) || MovieSearchService.new(api_id: movie_id).call.first

      if movie
        # @list.bookmarks.find_or_create_by(movie: movie)
        bookmark = Bookmark.find_by(list: @list, movie: movie) || Bookmark.new(list: @list, movie: movie)
        if bookmark.save
          new_bookmarks << bookmark
        end
      end
    end

    if new_bookmarks.any?
      render json: { success: true, bookmarks: new_bookmarks.as_json(include: { movie: { only: [:title, :poster_url, :release_date, :overview, :rating] } }) }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def update
    @bookmark = Bookmark.find(params[:id])

    if @bookmark.update(bookmark_params)
      redirect_to list_path(@bookmark.list)
    else
      render 'lists/show', status: :unprocessable_entity
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    redirect_to list_path(@bookmark.list), status: :see_other
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:comment)
  end
end
