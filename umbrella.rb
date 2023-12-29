require "http"
require "json"
require 'ascii_charts'

puts "What city are you checking?"
input_location = gets.chomp
input_location_nospace = input_location.gsub(" ", "%20")
puts "Checking the weather at #{input_location}...."

pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_KEY")
gmaps_api_key = ENV.fetch("GMAPS_KEY")

maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{input_location_nospace}&key=#{gmaps_api_key}"

raw_maps_resp = HTTP.get(maps_url)
parsed_maps_response = JSON.parse(raw_maps_resp.to_s)

maps_results = parsed_maps_response["results"]
maps_first_result = maps_results[0]
geo = maps_first_result["geometry"]
location = geo["location"]
latitude = location["lat"]
longitude = location["lng"]
puts "Your coordinates are #{latitude}, #{longitude}."

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_api_key}/#{latitude},#{longitude}"

raw_weather_resp = HTTP.get(pirate_weather_url)
parsed_weather_resp = JSON.parse(raw_weather_resp.to_s)
current_weather = parsed_weather_resp["currently"]
current_weather_summary = current_weather["summary"]
current_weather_temperature = current_weather["temperature"]

puts "The current weather is #{current_weather_summary.downcase}, with a temperature of #{current_weather_temperature}°F."

weather_forecast_minutely = parsed_weather_resp["minutely"]
weather_forecast_minutely_data = weather_forecast_minutely["data"]
weather_forecast_minutely_data.each { |minute_data|
  if minute_data["precipProbability"] >= 0.4 && (minute_data["precipType"] != "none") #just did 0.4 but was arbitrary choice
    time= Time.at(minute_data["time"])
    diff_in_time = time.min - Time.now.min
    precip_type = minute_data["precipType"]
    puts "Next hour: Possible #{precip_type} starting in #{diff_in_time} min."
    break
  end
}

weather_forecast_hourly = parsed_weather_resp["hourly"]
weather_forecast_hourly_data = weather_forecast_hourly["data"]
weather_array = []
ascii_array = []
(1..12).each { |hour|
  hour_data_hash = weather_forecast_hourly_data[hour]
  time = hour_data_hash["time"] # Prob not necessary here since it's already organized by hour but might be useful some other time
  probability = hour_data_hash["precipProbability"]
  precip_type = hour_data_hash["precipType"]
  hash = {:time => time, :probability => probability, :precip_type =>precip_type}
  weather_array.push(hash)
  ascii_array.push([hour, (probability*100).to_i])
}

umbrella_flag = false
weather_array.each { |hour|
  if hour[:probability] >= 0.1
    umbrella_flag = true
    break
  end
}

if umbrella_flag 
  puts "You might want to carry an umbrella!"
else
  puts "You probably won’t need an umbrella today."
end

# pp weather_array
# pp pirate_weather_url

puts "Hours from now vs Precipitation probability"
puts AsciiCharts::Cartesian.new(ascii_array, :bar => true, :hide_zero => true).draw
