import requests

API_KEY = "685ad477e96d47b1980112315262701"
CITY = "Cairo"

# =======================
# CURRENT WEATHER
# =======================
current_url = f"https://api.weatherapi.com/v1/current.json?key={API_KEY}&q={CITY}"
current_response = requests.get(current_url)
current_data = current_response.json()

current_temp = current_data["current"]["temp_c"]
current_humidity = current_data["current"]["humidity"]
current_wind = current_data["current"]["wind_kph"]
current_rain = current_data["current"]["precip_mm"]

print("=== Current Weather ===")
print("Temperature:", current_temp, "°C")
print("Humidity:", current_humidity, "%")
print("Wind Speed:", current_wind, "km/h")
print("Rain (mm):", current_rain)

# =======================
# FORECAST WEATHER (Today)
# =======================
forecast_url = f"https://api.weatherapi.com/v1/forecast.json?key={API_KEY}&q={CITY}&days=1"
forecast_response = requests.get(forecast_url)
forecast_data = forecast_response.json()

forecast_temp = forecast_data["forecast"]["forecastday"][0]["day"]["avgtemp_c"]
forecast_humidity = forecast_data["forecast"]["forecastday"][0]["day"]["avghumidity"]
forecast_rain_prob = forecast_data["forecast"]["forecastday"][0]["day"]["daily_chance_of_rain"]

print("\n=== Forecast (Today) ===")
print("Avg Temperature:", forecast_temp, "°C")
print("Avg Humidity:", forecast_humidity, "%")
print("Chance of Rain:", forecast_rain_prob, "%")
