require "http"
require "json"

puts "What city are you checking?"
input_location = gets.chomp
input_location = input_location.gsub(" ", "%20")

pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_KEY")
gmaps_api_key = ENV.fetch("GMAPS_KEY")

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_api_key}/41.8887,-87.6355"
maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{input_location}&key=#{gmaps_api_key}"

raw_resp = HTTP.get(maps_url)
parsed_response = JSON.parse(raw_resp)

results = parsed_response["results"]
first_result = results[0]
geo = first_result["geometry"]
location = geo["location"]
latitude = location["lat"]
longitude = location["lng"]

pp location
# pp raw_resp.to_s
