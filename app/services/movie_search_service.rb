require 'open-uri'
require 'json'

class MovieSearchService
  def initialize(query: nil, api_id: nil)
    @api_key = ENV["MOVIE_API"]
    @query = query
    @api_id = api_id
  end

  def call
    if @query
      search_movies
    elsif @api_id
      fetch_movie_details
    else
      []
    end
  end

  private

  def search_movies
    url = "https://api.themoviedb.org/3/search/movie?query=#{@query}&api_key=#{@api_key}"

    begin
      json = URI.open(url).read
      results = JSON.parse(json)['results']
      Rails.logger.debug "API Results: #{results.inspect}"

      # results.filter_map do |result|
      #   next if result['id'].nil? || result['title'].nil?
      results.map do |result|
        # movie = Movie.find_or_initialize_by(api_id: result['id'])
        # if movie.new_record?
        #   movie.title = result['title']
        #   movie.poster_url = "https://image.tmdb.org/t/p/w500#{result['poster_path']}" if result['poster_path']
        #   movie.rating = result['vote_average']
        #   movie.overview = result['overview'] || "No overview available."
        #   movie.save!
        #   Rails.logger.debug "Created Movie: #{movie.title} (API ID: #{movie.api_id})"
        # end
        # movie
        movie = Movie.find_by(api_id: result['id'])
        if movie.nil?
          Movie.create(
            title: result['title'],
            poster_url: "https://image.tmdb.org/t/p/w500#{result['poster_path']}",
            rating: result['vote_average'],
            overview: result['overview'] || "No overview available."
          )
        else
          movie
        end
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Error fetching movie search: #{e.message}")
      []
    end
  end

  def fetch_movie_details
    url = "https://api.themoviedb.org/3/movie/#{@api_id}?api_key=#{@api_key}"
    json = URI.open(url).read
    result = JSON.parse(json)
    Movie.find_or_create_by(api_id: result['id']) do |movie|
      movie.title = result['title']
      movie.poster_url = "https://image.tmdb.org/t/p/w500#{result['poster_path']}"
      movie.rating = result['vote_average']
      movie.overview = result['overview']
    end
  rescue OpenURI::HTTPError => e
    Rails.logger.error("Error fetching movie details: #{e.message}")
    nil
  end
end
