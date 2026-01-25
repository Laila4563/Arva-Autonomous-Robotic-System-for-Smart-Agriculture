import pandas as pd

# 1. Load the original dataset
df = pd.read_csv('Crop recommendation dataset.csv')

# 2. Define the list of crops mainly planted in Egypt
egypt_crops = [
    'rice', 'wheat', 'maize', 'sorghum', 'cowpea', 'bengalgram', 
    'soyabean', 'groundnut', 'sunflower', 'gingely', 'cotton', 
    'sugarcane', 'sugarbeet', 'tomato', 'onion', 'chillies', 
    'Cabbage', 'bhendi', 'brinjal', 'capsicum', 'pumpkin', 
    'cucumber', 'watermelon', 'muskmelon', 'french bean', 
    'peas', 'carrot', 'beetroot', 'radish', 'sweet potato', 
    'cauliflower', 'small onion'
]

# 3. Filter the dataframe to keep only relevant crops
df = df[df['CROPS'].isin(egypt_crops)]

# 4. Preprocessing: Cleaning and Standardizing
df['SOIL'] = df['SOIL'].str.replace(r'\xa0', ' ', regex=True).str.strip().str.lower()

# Rename Seasons to Egyptian agricultural terms
season_map = {
    'kharif': 'Summer',
    'rabi': 'Winter',
    'Zaid': 'Spring/Autumn'
}
df['SEASON'] = df['SEASON'].map(season_map)

df['SOWN'] = df['SOWN'].str.strip()
df['HARVESTED'] = df['HARVESTED'].str.strip()

# 5. Verification of Ranges (FIXED: Added RELATIVE_HUMIDITY)
# We aggregate the min and max for all 7 parameters provided by your sensor
range_summary = df.groupby('CROPS').agg({
    'SOIL_PH': ['min', 'max'],
    'TEMP': ['min', 'max'],
    'RELATIVE_HUMIDITY': ['min', 'max'], # Added this to fix the KeyError
    'N': ['min', 'max'],
    'P': ['min', 'max'],
    'K': ['min', 'max']
})

# Flatten the column names (e.g., 'RELATIVE_HUMIDITY_min')
range_summary.columns = [f"{col}_{stat}" for col, stat in range_summary.columns]
range_summary = range_summary.reset_index()

# 6. Save the final datasets
# Using 'egypt_crop_ready.csv' to match the recommendation script expectations
df.to_csv('Preprocessed Dataset.csv', index=False)
range_summary.to_csv('egypt_crop_ranges.csv', index=False)

print("--- Processing Complete ---")
print(f"Total Egyptian crops identified: {len(range_summary)}")
print("Check: 'RELATIVE_HUMIDITY_min' is now included in 'egypt_crop_ranges.csv'")