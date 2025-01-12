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

    # new_bookmarks = []

    # movie_ids.each do |movie_id|
    #   movie = Movie.find_by(api_id: movie_id) || MovieSearchService.new(api_id: movie_id).call.first

    #   if movie
    #     # @list.bookmarks.find_or_create_by(movie: movie)
    #     bookmark = Bookmark.find_by(list: @list, movie: movie) || Bookmark.new(list: @list, movie: movie)
    #     if bookmark.new_record? && bookmark.save
    #       new_bookmarks << bookmark
    #     end
    #   end
    # end

    # if new_bookmarks.any?
    #    # render json: { success: true, bookmarks: new_bookmarks.as_json(include: { movie: { only: [:api_id, :title, :poster_url, :release_date, :overview, :rating, :runtime, :genres] } }) }
    #   render turbo_stream: turbo_stream.append("bookmarks", partial: 'lists/card_movie', locals: { bookmark: new_bookmarks.last })
    # else
    #   render json: { success: false }, status: :unprocessable_entity
    # end

    new_bookmarks = movie_ids.map do |movie_id|
      movie = Movie.find_by(api_id: movie_id) || begin
        fetched_movie = MovieSearchService.new(api_id: movie_id).call.first
        fetched_movie.save if fetched_movie
        fetched_movie
      end
      Bookmark.find_or_create_by(list: @list, movie: movie)
    end

    @bookmarks = @list.bookmarks

    render turbo_stream: [
      turbo_stream.append("bookmarks", partial: "lists/card_movie", locals: { bookmark: new_bookmarks.last }),
      turbo_stream.replace("bookmark_count", partial: "lists/bookmark_count", locals: { count: @bookmarks.count })
    ]
  end

  def update
    @list = List.find(params[:list_id])
    # @bookmark = Bookmark.find(params[:id])
    @bookmark = @list.bookmarks.find(params[:id])

    if @bookmark.update(bookmark_params)
      # render partial: 'bookmarks/comment', locals: { bookmark: @bookmark }
      render turbo_stream: turbo_stream.replace("bookmark_#{@bookmark.id}", partial: 'bookmarks/comment', locals: { bookmark: @bookmark })
    else
      render turbo_stream: turbo_stream.replace("bookmark_#{@bookmark.id}", partial: 'bookmarks/comment', locals: { bookmark: @bookmark }), status: :unprocessable_entity
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
