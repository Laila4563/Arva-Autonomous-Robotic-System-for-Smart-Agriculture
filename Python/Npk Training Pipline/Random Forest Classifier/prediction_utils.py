import pandas as pd
import numpy as np
from prepare_dataset import apply_feature_engineering, scaler

def prepare_prediction_data(raw_data_points):
    """
    Prepare new data for prediction using the same preprocessing as training
    Returns: (original_df, engineered_df, scaled_df)
    """
    # Create DataFrame from raw data
    original_df = pd.DataFrame(
        raw_data_points, 
        columns=['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']
    )
    
    # Apply the same feature engineering used in training
    engineered_df = apply_feature_engineering(original_df)
    
    # Scale the data using the training scaler
    scaled_data = scaler.transform(engineered_df)
    scaled_df = pd.DataFrame(scaled_data, columns=engineered_df.columns)
    
    return original_df, engineered_df, scaled_df

def get_sample_data():
    """Return standardized sample data for predictions"""
    return [
        [90, 42, 52, 27.33, 86.59, 6.5, 239.2],  # Expected: rice
        [1, 62, 28, 31.86, 90.5, 5.0, 45.05],    # Expected: mungbean
        [5, 20, 50, 25.5, 84.2, 8.0, 100.6],     # Expected: pomegranate
        [40, 40, 40, 25.0, 80.0, 7.0, 150.0]     # Generic case
    ]

def format_prediction_output(predictions, probabilities, input_data, model_name):
    """Format and display prediction results"""
    print(f"\n{model_name.upper()} PREDICTION RESULTS")
    print("=" * 90)
    print(f"{'Sample':<6} {'Predicted Crop':<20} {'Probability':<15} {'N':<4} {'P':<4} {'K':<4} {'Temp':<8} {'Humidity':<10} {'pH':<6} {'Rainfall':<10}")
    print("-" * 90)

    max_probs = [probs.max() for probs in probabilities]
    
    for i, (idx, row) in enumerate(input_data.iterrows()):
        print(f"{i+1:<6} {predictions[i]:<20} {max_probs[i]:<15.3f} {row['N']:<4} {row['P']:<4} {row['K']:<4} {row['temperature']:<8.1f} {row['humidity']:<10.1f} {row['ph']:<6.1f} {row['rainfall']:<10.1f}")

def save_prediction_results(original_df, predictions, probabilities, model_name):
    """Save prediction results to CSV"""
    result_df = original_df.copy()
    result_df['Predicted_Crop'] = predictions
    result_df['Prediction_Probability'] = [probs.max() for probs in probabilities]
    
    output_file = f'model_results/{model_name}_predictions.csv'
    result_df.to_csv(output_file, index=False)
    return output_file