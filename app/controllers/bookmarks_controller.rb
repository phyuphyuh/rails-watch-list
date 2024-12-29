class BookmarksController < ApplicationController
  # def new
  #   @list = List.find(params[:list_id])
  #   @bookmark = Bookmark.new
  # end

  def create
    @list = List.find(params[:list_id])
    @movie = Movie.find_by(api_id: params[:movie_id])
    # @bookmark = Bookmark.new(bookmark_params)
    # @bookmark.list = @list
    @bookmark = @list.bookmarks.new(bookmark_params.merge(movie: @movie))

    if @bookmark.save
      redirect_to list_path(@list)
    else
      render 'lists/show', status: :unprocessable_entity
    end
  end

  def search
    movie_service = MovieSearchService.new(params[:query])
    @movies = movie_service.call

    respond_to do |format|
      format.js { render 'search_results' }
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
