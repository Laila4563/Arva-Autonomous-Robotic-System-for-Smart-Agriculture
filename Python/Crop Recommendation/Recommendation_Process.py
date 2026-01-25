import pandas as pd

# Load the datasets prepared by your preprocessing script
# 'Preprocessed Dataset.csv' is the cleaned data
# 'egypt_crop_ranges.csv' contains the NPK/Climate logic bounds
try:
    df = pd.read_csv('Preprocessed Dataset.csv')
    ranges = pd.read_csv('egypt_crop_ranges.csv')
except FileNotFoundError:
    print("Error: Please run your preprocessing script first to generate the CSV files.")

def get_recommendation(n_val, p_val, k_val, ph_val, temp_val, hum_val):
    recommendations = []

    # Iterate through each crop and its verified ranges
    for index, row in ranges.iterrows():
        # Check if sensor values fall within the crop's specific bounds
        # Logic includes RELATIVE_HUMIDITY to match your 7-in-1 sensor
        if (row['N_min'] <= n_val <= row['N_max'] and
            row['P_min'] <= p_val <= row['P_max'] and
            row['K_min'] <= k_val <= row['K_max'] and
            row['SOIL_PH_min'] <= ph_val <= row['SOIL_PH_max'] and
            row['TEMP_min'] <= temp_val <= row['TEMP_max'] and
            row['RELATIVE_HUMIDITY_min'] <= hum_val <= row['RELATIVE_HUMIDITY_max']):
            
            recommendations.append(row['CROPS'])

    return recommendations

def print_crop_info(crop_name):
    # Filter the dataset for the specific crop
    crop_data = df[df['CROPS'] == crop_name]
    
    # Extract unique options and ranges
    seasons = ", ".join(crop_data['SEASON'].unique())
    soils = ", ".join([s.title() for s in crop_data['SOIL'].unique()])
    water_sources = ", ".join([w.title() for w in crop_data['WATER_SOURCE'].unique()])
    
    # Month Ranges (First month to Last month)
    sown_months = crop_data['SOWN'].unique()
    harvest_months = crop_data['HARVESTED'].unique()
    
    duration_min = int(crop_data['CROPDURATION'].min())
    duration_max = int(crop_data['CROPDURATION_MAX'].max())

    print(f"\n🌾 RECOMMENDED CROP: {crop_name.upper()}")
    print("-" * 45)
    print(f"📅 Egyptian Season: {seasons}")
    print(f"🌱 Suitable Soils:  {soils}")
    print(f"💧 Water Sources:   {water_sources}")
    print(f"🚜 Sowing Period:   {sown_months[0]} to {sown_months[-1]}")
    print(f"✂️ Harvest Period:  {harvest_months[0]} to {harvest_months[-1]}")
    print(f"⏳ Growth Cycle:    {duration_min} - {duration_max} days")
    print("-" * 45)

# --- TEST SCENARIO (SENSOR SIMULATION) ---
s_n, s_p, s_k = 95, 50, 55
s_ph, s_temp, s_hum = 7.6, 28, 80.0  

# Run the recommendation
results = get_recommendation(s_n, s_p, s_k, s_ph, s_temp, s_hum)

# Output results
if results:
    print(f"Found {len(results)} recommendation(s) based on sensor data:")
    for crop in results:
        print_crop_info(crop)
else:
    print("❌ No specific Egyptian crop matched these exact sensor conditions.")
    print("Hint: Try checking your Humidity or Temperature ranges in egypt_crop_ranges.csv")