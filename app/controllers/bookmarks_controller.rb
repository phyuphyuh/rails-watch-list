class BookmarksController < ApplicationController
  # def new
  #   @list = List.find(params[:list_id])
  #   @bookmark = Bookmark.new
  # end

  def create
    @list = List.find(params[:list_id])
    # @bookmark = Bookmark.new(bookmark_params)
    # @bookmark.list = @list

    movie = Movie.find_by(api_id: params[:api_id])

    unless movie
      movie = MovieSearchService.new(api_id: params[:api_id]).call.first
    end

    @bookmark = @list.bookmarks.new(movie: movie, comment: bookmark_params[:comment])

    if @bookmark.save
      # redirect_to list_path(@list)
      respond_to do |format|
        format.html { redirect_to list_path(@list) }
        format.json { render json: { success: true } }
      end
    else
      # render 'lists/show', status: :unprocessable_entity
      respond_to do |format|
        format.html { render 'lists/show', status: :unprocessable_entity }
        format.json { render json: { success: false }, status: :unprocessable_entity }
      end
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
