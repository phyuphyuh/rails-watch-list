# require 'open-uri'
# require 'json'
# Movie.destroy_all

# def api_key
#   ENV["MOVIE_API"]
# end

# (1..15).to_a.each do |num|
#   api_data = { key: api_key }
#   # url = "http://tmdb.lewagon.com/movie/top_rated?page=#{num}"
#   url = "https://api.themoviedb.org/3/movie/top_rated?page=#{num}&api_key=#{api_data[:key]}"
#   response = JSON.parse(URI.open(url).read)

#   response['results'].each do |movie_hash|
#     Movie.create!(
#       title: movie_hash['title'],
#       poster_url: "https://image.tmdb.org/t/p/w500#{movie_hash['poster_path']}",
#       rating: movie_hash['vote_average'],
#       overview: movie_hash['overview']
#     )
#   end
# end
