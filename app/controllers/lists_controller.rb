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
    @list = List.new(list_params)
    if @list.save
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
end
