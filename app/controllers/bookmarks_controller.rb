class BookmarksController < ApplicationController
  # def new
  #   @list = List.find(params[:list_id])
  #   @bookmark = Bookmark.new
  # end

  def create
    @list = List.find(params[:list_id])
    # @bookmark = Bookmark.new(bookmark_params)
    # @bookmark.list = @list

    movie_ids = params[:movie_ids].is_a?(Array) ? [params[:movie_id]] : params[:movie_ids].to_s.split(',')

    movie_ids.each do |movie_id|
      movie = Movie.find_by(api_id: movie_id) || MovieSearchService.new(api_id: movie_id).call.first

      if movie
        @list.bookmarks.find_or_create_by(movie: movie)
      end
    end
      # if movie
      #   bookmark = @list.bookmarks.find_by(movie: movie)
      #   if bookmark
      #     @bookmark = bookmark
      #   else
      #     @bookmark = Bookmark.new(movie: movie, list: @list)
      #   end

      #   if @bookmark.save
      #     next
      #   else
      #     render 'lists/show', status: :unprocessable_entity
      #   end
      # end

    respond_to do |format|
      format.html { redirect_to list_path(@list) }
      format.json { render json: { success: true } }
    end
  rescue => e
    Rails.logger.error("Error adding bookmarks: #{e.message}")
    respond_to do |format|
      format.html { render 'lists/show', status: :unprocessable_entity }
      format.json { render json: { success: false }, status: :unprocessable_entity }
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
