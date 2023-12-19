require "http"
require "json"

puts "What city are you checking?"
input_location = gets.chomp
input_location = input_location.gsub(" ", "%20")

pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_KEY")
gmaps_api_key = ENV.fetch("GMAPS_KEY")

maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{input_location}&key=#{gmaps_api_key}"

raw_maps_resp = HTTP.get(maps_url)
parsed_maps_response = JSON.parse(raw_maps_resp)

maps_results = parsed_maps_response["results"]
maps_first_result = maps_results[0]
geo = maps_first_result["geometry"]
location = geo["location"]
latitude = location["lat"]
longitude = location["lng"]

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_api_key}/#{latitude},#{longitude}"

raw_weather_resp = HTTP.get(pirate_weather_url)
parsed_weather_resp = JSON.parse(raw_weather_resp)
current_weather = parsed_weather_resp["currently"]
current_weather_summary = current_weather["summary"]
current_weather_temperature = current_weather["temperature"]

puts "The current weather is #{current_weather_summary.downcase}, with a temperature of #{current_weather_temperature}"
# pp current_weather_summary
# pp current_weather_temperature
