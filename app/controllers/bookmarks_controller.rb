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

    new_bookmarks = movie_ids.map do |movie_id|
      movie = Movie.find_by(api_id: movie_id) || begin
        fetched_movie = MovieSearchService.new(api_id: movie_id).call.first
        fetched_movie.save if fetched_movie
        fetched_movie
      end

      if movie.runtime.blank? || movie.genres.blank?
        detailed_movie = MovieSearchService.new(api_id: movie.api_id).call
        movie.update(runtime: detailed_movie.runtime, genres: detailed_movie.genres) if detailed_movie
      end

      unless Bookmark.exists?(list: @list, movie: movie)
        Bookmark.find_or_create_by(list: @list, movie: movie)
      end
    end.compact

    @bookmarks = @list.bookmarks

    if new_bookmarks.any?
      render turbo_stream: [
        turbo_stream.append("bookmarks", partial: "lists/card_movie", locals: { bookmark: new_bookmarks.last }),
        turbo_stream.replace("bookmark_count", partial: "lists/bookmark_count", locals: { count: @bookmarks.count })
      ]
    end
  end

  def update
    @list = List.find(params[:list_id])
    # @bookmark = Bookmark.find(params[:id])
    @bookmark = @list.bookmarks.find(params[:id])

    if @bookmark.update(bookmark_params)
      # render partial: 'bookmarks/comment', locals: { bookmark: @bookmark }
      render turbo_stream: turbo_stream.replace("bookmark_comment_#{@bookmark.id}", partial: 'bookmarks/comment', locals: { bookmark: @bookmark })
    else
      render turbo_stream: turbo_stream.replace("bookmark_comment_#{@bookmark.id}", partial: 'bookmarks/comment', locals: { bookmark: @bookmark }), status: :unprocessable_entity
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])

    if @bookmark.destroy
    # redirect_to list_path(@bookmark.list), status: :see_other
      render turbo_stream: [
        turbo_stream.remove("bookmark_#{@bookmark.id}"),
        turbo_stream.replace("bookmark_count", partial: "lists/bookmark_count", locals: { count: @bookmark.list.bookmarks.count })
      ]
    end
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:comment)
  end
end
