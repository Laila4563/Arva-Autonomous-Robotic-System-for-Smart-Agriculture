import pandas as pd
import matplotlib.pyplot as plt
import os

# === CONFIGURATION ===
# Update this path if your run folder name is different (e.g. train2, train3)
results_path = r"runs/detect/plantvillage_yolov8n/results.csv"

# === LOAD RESULTS ===
if not os.path.exists(results_path):
    raise FileNotFoundError(f"Could not find {results_path}. Check your run folder name.")

df = pd.read_csv(results_path, encoding='latin1', engine='python', on_bad_lines='skip')
print(f"Loaded YOLOv8 training results from: {results_path}")
print(f"Total epochs: {len(df)}\n")

# === SUMMARY TABLE ===
summary_cols = [
    'epoch', 
    'train/box_loss', 'train/cls_loss', 'train/dfl_loss',
    'val/box_loss', 'val/cls_loss', 'val/dfl_loss',
    'metrics/precision(B)', 'metrics/recall(B)', 
    'metrics/mAP50(B)', 'metrics/mAP50-95(B)'
]

# Some YOLO versions might not have val/ columns — handle that gracefully
for col in summary_cols:
    if col not in df.columns:
        df[col] = None

summary = df[summary_cols]
summary = summary.rename(columns={
    'train/box_loss': 'Train Box Loss',
    'train/cls_loss': 'Train Class Loss',
    'train/dfl_loss': 'Train DFL Loss',
    'val/box_loss': 'Val Box Loss',
    'val/cls_loss': 'Val Class Loss',
    'val/dfl_loss': 'Val DFL Loss',
    'metrics/precision(B)': 'Precision',
    'metrics/recall(B)': 'Recall',
    'metrics/mAP50(B)': 'mAP50',
    'metrics/mAP50-95(B)': 'mAP50-95'
})

# === DISPLAY CLEAN TABLES ===
print("Last 10 Epochs Summary:")
print(summary.round(4).tail(10).to_string(index=False))

# === PLOTS ===
plt.style.use('seaborn-v0_8-muted')
plt.figure(figsize=(10,6))
plt.plot(df['epoch'], df['metrics/precision(B)'], label='Precision', marker='o')
plt.plot(df['epoch'], df['metrics/recall(B)'], label='Recall', marker='o')
plt.plot(df['epoch'], df['metrics/mAP50(B)'], label='mAP50', marker='o')
plt.plot(df['epoch'], df['metrics/mAP50-95(B)'], label='mAP50-95', marker='o')

plt.title('YOLOv8 Validation Metrics Over Epochs')
plt.xlabel('Epoch')
plt.ylabel('Score')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

# === TRAIN VS VAL LOSSES ===
plt.figure(figsize=(10,6))
plt.plot(df['epoch'], df['train/box_loss'], label='Train Box Loss')
plt.plot(df['epoch'], df['val/box_loss'], label='Val Box Loss')
plt.plot(df['epoch'], df['train/cls_loss'], label='Train Class Loss')
plt.plot(df['epoch'], df['val/cls_loss'], label='Val Class Loss')
plt.plot(df['epoch'], df['train/dfl_loss'], label='Train DFL Loss')
plt.plot(df['epoch'], df['val/dfl_loss'], label='Val DFL Loss')

plt.title('YOLOv8 Training vs Validation Losses')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

print("\nAnalysis complete! Metrics and plots displayed successfully.")
