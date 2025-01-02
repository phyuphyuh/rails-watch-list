class ListsController < ApplicationController
  before_action :set_list, only: [:show, :destroy]

  def index
    @lists = List.all
    @list = List.new
  end

  def show
    @bookmark = Bookmark.new
    @movies = params[:query].present? ? MovieSearchService.new(query: params[:query]).call : []

    respond_to do |format|
      format.html
      format.text { render partial: 'bookmarks/search_results', locals: { movies: @movies }, formats: [:html] }
    end
  end

  def new
    @list = List.new
    # query = params[:query]
    # @movies = query.present? ? MovieSearchService.new(query: query).call : []
    @movies = params[:query].present? ? MovieSearchService.new(query: params[:query]).call : []

    respond_to do |format|
      format.html
      format.text { render partial: 'bookmarks/search_results', locals: { movies: @movies }, formats: [:html] }
    end

  end

  def create
    Rails.logger.debug "Movie IDs from params: #{params[:movie_ids]}"

    @list = List.new(list_params)

    if @list.save
      add_temporary_bookmarks_to_list(@list, params[:movie_ids]&.split(','))
      redirect_to list_path(@list)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy
    redirect_to lists_path, status: :see_other
  end

  private

  def list_params
    params.require(:list).permit(:name, :description, :photo)
  end

  def set_list
    @list = List.find(params[:id])
  end

  def add_temporary_bookmarks_to_list(list, movie_ids)
    return unless movie_ids.present?

    movie_ids.each do |movie_id|
      movie = Movie.find_by(api_id: movie_id) || MovieSearchService.new(api_id: movie_id).call.first

      bookmark = list.bookmarks.create(movie: movie) if movie
      unless bookmark.save
        Rails.logger.error("Bookmark failed to save: #{bookmark.errors.full_messages.join(", ")}")
      end
    end
  end
end
