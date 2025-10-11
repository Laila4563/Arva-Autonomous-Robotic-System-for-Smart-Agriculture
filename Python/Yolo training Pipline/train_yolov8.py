# train_yolov8.py
from ultralytics import YOLO
import os

# Training config
MODEL = 'yolov8n.pt'  # Base model (only used if no checkpoint exists)
DATA = 'dataset/dataset.yaml'
TOTAL_EPOCHS = 50
BATCH = 16
IMG_SIZE = 640
NAME = 'plantvillage_yolov8n'

# Path to your previous run checkpoint
CHECKPOINT_PATH = f"runs/detect/{NAME}/weights/last.pt"  # Adjust if needed

if __name__ == '__main__':
    # If a checkpoint exists, resume training
    if os.path.exists(CHECKPOINT_PATH):
        print(f"Checkpoint detected: {CHECKPOINT_PATH}")
        model = YOLO(CHECKPOINT_PATH)  # Loads model + optimizer state
        print("Resuming training with optimizer state preserved...")
        model.train(resume=True)  # Continues from last epoch until TOTAL_EPOCHS is reached
    else:
        print("No checkpoint found — starting fresh training...")
        model = YOLO(MODEL)
        model.train(data=DATA, epochs=TOTAL_EPOCHS, imgsz=IMG_SIZE, batch=BATCH, name=NAME)

    print("Training finished. Generating confusion matrix...")

    # Run validation to produce confusion matrix
    results = model.val(data=DATA, split="val", plots=True)  # plots=True automatically generates confusion matrix

    print("Confusion matrix and plot saved in runs/detect/{NAME}/")
