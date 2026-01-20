import pandas as pd
import joblib
from prediction_utils import prepare_prediction_data, get_sample_data, format_prediction_output, save_prediction_results

print("=" * 60)
print("RANDOM FOREST CLASSIFIER (RFC) PREDICTION")
print("=" * 60)

# Load model and metrics
model = joblib.load('rfc_model.pkl')
history_df = pd.read_csv('model_results/rfc_history.csv')
feature_importance_df = pd.read_csv('model_results/rfc_feature_importance.csv')

print(f"✓ Model loaded: Train Acc: {history_df['Train Accuracy'].iloc[0]}, Test Acc: {history_df['Test Accuracy'].iloc[0]}")

# Prepare data using shared function
sample_data = get_sample_data()
original_df, engineered_df, scaled_df = prepare_prediction_data(sample_data)

# Make predictions (RFC uses unscaled data)
predictions = model.predict(engineered_df)
probabilities = model.predict_proba(engineered_df)

# Display results
format_prediction_output(predictions, probabilities, original_df, "RFC")

# Save results
output_file = save_prediction_results(original_df, predictions, probabilities, 'rfc')
print(f"\n✓ Predictions saved to: {output_file}")