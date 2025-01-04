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

      results.map do |result|
        next if result['id'].nil?
        movie = Movie.find_or_initialize_by(api_id: result['id'])
        movie.update(
          title: result['title'],
          release_date: result['release_date']&.split('-')&.first,
          poster_url: "https://image.tmdb.org/t/p/w500#{result['poster_path']}",
          rating: result['vote_average'],
          overview: result['overview'] || "No overview available."
        )
        movie
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
    movie = Movie.find_or_initialize_by(api_id: result['id'])
    movie.update(
      api_id: result['id'],
      title: result['title'],
      release_date: result['release_date']&.split('-')&.first,
      poster_url: "https://image.tmdb.org/t/p/w500#{result['poster_path']}",
      rating: result['vote_average'],
      overview: result['overview']
    )
    movie
  rescue OpenURI::HTTPError => e
    Rails.logger.error("Error fetching movie details: #{e.message}")
    nil
  end
end
