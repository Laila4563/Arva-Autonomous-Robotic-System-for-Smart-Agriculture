import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, learning_curve, cross_val_score 
from sklearn.preprocessing import StandardScaler, RobustScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix 
import matplotlib.pyplot as plt 
import seaborn as sns 
import os
import joblib

# Import the dataset variables from prepare_dataset
from prepare_dataset import X_train, X_test, y_train, y_test, X_train_scaled, X_test_scaled

# Create directories for saving results
os.makedirs('model_results', exist_ok=True)
os.makedirs('model_images', exist_ok=True)

# --- Plotting Functions ---

def plot_confusion_matrix(cm, class_names, name):
    """Plots and saves the confusion matrix."""
    plt.figure(figsize=(12, 10))
    # Use a modern color scheme and ensure readability
    sns.heatmap(
        cm, 
        annot=True, 
        fmt='d', 
        cmap='rocket_r', # Changed to a high-contrast palette
        xticklabels=class_names, 
        yticklabels=class_names
    )
    plt.title(f'Confusion Matrix for {name}', fontsize=16)
    plt.ylabel('True Label', fontsize=14)
    plt.xlabel('Predicted Label', fontsize=14)
    plt.tight_layout()
    
    # Save the figure
    filename = f"model_images/{name.replace(' ', '_').replace('(', '').replace(')', '')}_confusion_matrix.png"
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    plt.show()
    plt.close()  # Close the figure to free memory

def plot_learning_curve(model, X, y, title, cv=5, n_jobs=-1, train_sizes=np.linspace(.1, 1.0, 5), is_scaled=False):
    """Plots and saves the learning curve to visualize bias-variance trade-off."""
    plt.figure(figsize=(10, 6))
    plt.title(title, fontsize=16)
    plt.xlabel("Training Examples", fontsize=14)
    plt.ylabel("Score (Accuracy)", fontsize=14)
    
    # Use the appropriate data for the learning curve
    X_curve = X_train_scaled if is_scaled and 'X_train_scaled' in globals() else X
    
    # Generate the learning curve scores
    train_sizes, train_scores, test_scores = learning_curve(
        model, X_curve, y, cv=cv, n_jobs=n_jobs, train_sizes=train_sizes, scoring='accuracy'
    )

    train_scores_mean = np.mean(train_scores, axis=1)
    train_scores_std = np.std(train_scores, axis=1)
    test_scores_mean = np.mean(test_scores, axis=1)
    test_scores_std = np.std(test_scores, axis=1)

    # Plot the curves
    plt.grid(linestyle='--')
    plt.fill_between(train_sizes, train_scores_mean - train_scores_std,
                     train_scores_mean + train_scores_std, alpha=0.1, color="#2ecc71") # Greenish
    plt.fill_between(train_sizes, test_scores_mean - test_scores_std,
                     test_scores_mean + test_scores_std, alpha=0.1, color="#e74c3c") # Reddish
    
    plt.plot(train_sizes, train_scores_mean, 'o-', color="#27ae60", label="Training score (High Bias Check)")
    plt.plot(train_sizes, test_scores_mean, 'o-', color="#c0392b", label="Cross-validation score (High Variance Check)")
    
    plt.legend(loc="lower right")
    plt.tight_layout()
    
    # Save the figure
    filename = f"model_images/{title.replace(' ', '_').replace('(', '').replace(')', '')}_learning_curve.png"
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    plt.show()
    plt.close()  # Close the figure to free memory

# --- NEW: Function to format the individual model table ---
def create_vgg_style_table(name, train_metrics, test_metrics):
    """Generates a Markdown table for a single model matching the VGG structure."""
    
    metrics_list = ['Accuracy', 'Precision', 'Recall', 'F1 Score']
    
    # Create the DataFrame
    df = pd.DataFrame({
        f'{name} Training': [train_metrics.get(m, np.nan) for m in metrics_list],
        f'{name} Testing': [test_metrics.get(m, np.nan) for m in metrics_list]
    }, index=metrics_list)
    
    # Format to 4 decimal places
    for col in df.columns:
        df[col] = df[col].map('{:.4f}'.format)
        
    # Reset index to make 'Metric' a column
    df = df.reset_index().rename(columns={'index': 'Metric'})
    
    # Print the detailed table
    print(f"\n--- Detailed Performance Table: {name} ---")
    print(df.to_markdown(index=False, numalign="left", stralign="left"))
    print("-" * 60)
    
    return df

# --- NEW: Function to save metrics to CSV ---
def save_metrics_to_csv(history_metrics, train_metrics, test_metrics, model_name):
    """Save all model metrics to CSV files."""
    
    # 1. Save history metrics (overall performance)
    history_df = pd.DataFrame([history_metrics])
    history_csv_path = f'model_results/{model_name}_history.csv'
    history_df.to_csv(history_csv_path, index=False)
    print(f"✓ Saved history metrics to: {history_csv_path}")
    
    # 2. Save detailed metrics
    detailed_metrics = {
        'Training': train_metrics,
        'Testing': test_metrics
    }
    detailed_df = pd.DataFrame(detailed_metrics).T
    detailed_csv_path = f'model_results/{model_name}_detailed_metrics.csv'
    detailed_df.to_csv(detailed_csv_path)
    print(f"✓ Saved detailed metrics to: {detailed_csv_path}")
    
    # 3. Save feature importance for Random Forest
    if hasattr(trained_model, 'feature_importances_'):
        feature_importance_df = pd.DataFrame({
            'Feature': X_train.columns,
            'Importance': trained_model.feature_importances_
        }).sort_values('Importance', ascending=False)
        
        feature_csv_path = f'model_results/{model_name}_feature_importance.csv'
        feature_importance_df.to_csv(feature_csv_path, index=False)
        print(f"✓ Saved feature importance to: {feature_csv_path}")
    
    # 4. Save model parameters
    params_df = pd.DataFrame([trained_model.get_params()])
    params_csv_path = f'model_results/{model_name}_parameters.csv'
    params_df.to_csv(params_csv_path, index=False)
    print(f"✓ Saved model parameters to: {params_csv_path}")

# --- Model Evaluation Function (MODIFIED to return detailed metrics) ---
def evaluate_and_report(model, X_train, y_train, X_test, y_test, name, is_scaled=False):
    """Trains, evaluates, and reports metrics for a single model."""
    
    # Determine which data set to use based on model scaling requirement
    X_train_data = X_train_scaled if is_scaled and 'X_train_scaled' in globals() else X_train
    X_test_data = X_test_scaled if is_scaled and 'X_test_scaled' in globals() else X_test
    
    # Train the model
    print(f"\nTraining {name}...")
    model.fit(X_train_data, y_train)

    # Predictions
    y_train_pred = model.predict(X_train_data)
    y_test_pred = model.predict(X_test_data)

    # Calculate accuracies
    train_accuracy = accuracy_score(y_train, y_train_pred)
    test_accuracy = accuracy_score(y_test, y_test_pred)
    accuracy_difference = train_accuracy - test_accuracy
    
    # Calculate Cross-Validation Score (using the training data)
    cv_data = X_train_scaled if is_scaled else X_train
    cv_scores = cross_val_score(model, cv_data, y_train, cv=5, scoring='accuracy', n_jobs=-1)
    cv_mean_score = np.mean(cv_scores)

    # --- Bias/Variance Estimation ---
    bias_estimate = "Low" if train_accuracy > 0.90 else "High"
    variance_estimate = "Low" if (train_accuracy - cv_mean_score) < 0.02 else "High" 

    print(f"\n--- {name} Performance ---")
    print(f"Training Set Accuracy: {train_accuracy:.4f} ({(train_accuracy * 100):.2f}%)")
    print(f"Cross-Validation (CV) Score: {cv_mean_score:.4f} ({(cv_mean_score * 100):.2f}%)")
    print(f"Test Set Accuracy: {test_accuracy:.4f} ({(test_accuracy * 100):.2f}%)")
    print(f"Bias Estimate: {bias_estimate} (Train score is high)")
    print(f"Variance Estimate: {variance_estimate} (Train-CV gap is {(train_accuracy - cv_mean_score)*100:.2f}%)")


    # Bias/Variance Interpretation 
    if accuracy_difference > 0.05:
        print("Interpretation: High Variance (Possible Overfitting). Test set accuracy significantly lower than training set.")
    elif train_accuracy < 0.90 and test_accuracy < 0.90:
        print("Interpretation: High Bias (Possible Underfitting). Model is too simple or features are insufficient.")
    else:
        print("Interpretation: Balanced Fit. High performance on both sets, suggesting low bias and manageable variance.")
    
    # Get detailed classification reports as dictionaries
    report_train = classification_report(y_train, y_train_pred, zero_division=0, output_dict=True)
    report_test = classification_report(y_test, y_test_pred, zero_division=0, output_dict=True)

    # Extract Macro Averages (similar to the VGG-style table)
    train_metrics = {
        'Accuracy': train_accuracy,
        'Precision': report_train['macro avg']['precision'],
        'Recall': report_train['macro avg']['recall'],
        'F1 Score': report_train['macro avg']['f1-score'],
    }

    test_metrics = {
        'Accuracy': test_accuracy,
        'Precision': report_test['macro avg']['precision'],
        'Recall': report_test['macro avg']['recall'],
        'F1 Score': report_test['macro avg']['f1-score'],
    }

    print("\nDetailed Training Set Classification Report:")
    print(classification_report(y_train, y_train_pred, zero_division=0))

    print("\nDetailed Test Set Classification Report:")
    print(classification_report(y_test, y_test_pred, zero_division=0))
    
    # Generate and plot Confusion Matrix
    cm = confusion_matrix(y_test, y_test_pred, labels=model.classes_)
    plot_confusion_matrix(cm, model.classes_, name)

    # Generate and plot Learning Curve
    plot_learning_curve(
        model, 
        X_train, 
        y_train, 
        title=f"{name} Learning Curve",
        is_scaled=is_scaled 
    )
    
    # Return the metrics for the history table and the new detailed metrics
    history_metrics = {
        'Model': name,
        'Train Accuracy': train_accuracy,
        'CV Score': cv_mean_score,
        'Test Accuracy': test_accuracy,
        'Bias Estimate': bias_estimate,
        'Variance Estimate': variance_estimate,
        'is_scaled': is_scaled # Include scaling status for prediction
    }
    
    return model, history_metrics, train_metrics, test_metrics

# Random Forest Model
RANDOM_SEED = 42
model_instance = RandomForestClassifier(
    random_state=RANDOM_SEED, 
    n_estimators=100, 
    max_depth=10, 
    min_samples_split=5 
)
name = "Random Forest Classifier (RFC)"
is_scaled = False

trained_model, history_metrics, train_metrics, test_metrics = evaluate_and_report(
    model_instance, 
    X_train, y_train, 
    X_test, y_test, 
    name, 
    is_scaled
)

# NEW: Print the VGG-style table for this model
create_vgg_style_table(name, train_metrics, test_metrics)

# Save the trained model
joblib.dump(trained_model, 'rfc_model.pkl')
print(f"✓ Saved trained model to: rfc_model.pkl")

# Save all metrics to CSV files
print("\n" + "="*60)
print("SAVING RESULTS TO CSV FILES:")
print("="*60)
save_metrics_to_csv(history_metrics, train_metrics, test_metrics, 'rfc')

