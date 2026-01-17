import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, RobustScaler

# --- Configuration ---
DATA_FILE = "Crop_recommendation.csv"
RANDOM_SEED = 42

# --- Feature Engineering Function (to be reused) ---
def apply_feature_engineering(df):
    """Apply feature engineering to a DataFrame - reusable for prediction data"""
    df_engineered = df.copy()
    # Safely calculate ratios, replacing division-by-zero results with NaN
    df_engineered['N_to_K'] = df_engineered.apply(lambda row: row['N'] / row['K'] if row['K'] != 0 else np.nan, axis=1)
    df_engineered['P_to_K'] = df_engineered.apply(lambda row: row['P'] / row['K'] if row['K'] != 0 else np.nan, axis=1)
    df_engineered['NPK_Sum'] = df_engineered['N'] + df_engineered['P'] + df_engineered['K']
    df_engineered['Moisture_Index'] = df_engineered.apply(lambda row: row['humidity'] / row['rainfall'] if row['rainfall'] != 0 else np.nan, axis=1)
    # Impute NaNs created by division-by-zero with the mean of the new feature
    df_engineered.fillna(df_engineered.mean(numeric_only=True), inplace=True)
    return df_engineered

# --- 1. Data Loading ---
print(f"Loading data from {DATA_FILE}...")
try:
    df = pd.read_csv(DATA_FILE)
except Exception as e:
    print(f"Error loading file: {e}")
    df = pd.DataFrame() 
    if df.empty:
        exit()

# --- 2. Feature Engineering & Selection ---
print("Applying Feature Engineering (N:K, P:K Ratios, NPK Sum, Moisture Index)...")
df = apply_feature_engineering(df)

# --- 3. Preprocessing: Split and Scale (Outlier Robust Scaling Implemented) ---
X = df.drop(['label'], axis=1)
y = df['label']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=RANDOM_SEED)

# *** OUTLIER FIX IMPLEMENTATION: RobustScaler ***
print("\nFIXING OUTLIERS: Using RobustScaler for sensitive models...")
scaler = RobustScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Convert scaled data back to DataFrame 
X_train_scaled = pd.DataFrame(X_train_scaled, columns=X_train.columns)
X_test_scaled = pd.DataFrame(X_test_scaled, columns=X_test.columns)

print("Dataset preparation completed!")

# Export variables and functions for other modules
__all__ = ['X_train', 'X_test', 'y_train', 'y_test', 'X_train_scaled', 'X_test_scaled', 'scaler', 'apply_feature_engineering']