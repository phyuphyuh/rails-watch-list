require 'open-uri'
require 'json'

class MovieSearchService
  def api_key
    ENV["MOVIE_API"]
  end

  def initialize(query)
    api_data = { key: api_key }
    @query = query
    @url = "https://api.themoviedb.org/3/search/movie?query=#{query}&api_key=#{api_data[:key]}"
  end

  def call
    return [] unless @query.present?
    results = JSON.parse(URI.open(url).read)['results']
  rescue OpenURI:HTTPError => e
    Rails.logger.error("MovieSearchService Error: #{e.message}")
    []
  end
end
