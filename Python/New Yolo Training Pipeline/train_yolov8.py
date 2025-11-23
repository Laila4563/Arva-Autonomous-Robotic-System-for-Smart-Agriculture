# train_yolov8_simple.py - Minimal working version
from ultralytics import YOLO
import os

# Minimal training config
MODEL = 'yolov8n.pt'
DATA = 'dataset2/dataset.yaml'
TOTAL_EPOCHS = 30
BATCH = 4  # Very small batch size
IMG_SIZE = 640
NAME = 'plantvillage_simple'

# Checkpoint path
CHECKPOINT_PATH = f"runs/detect/{NAME}/weights/last.pt"

def main():
    print("🚀 Starting MINIMAL YOLOv8 Training")
    
    # Check for existing checkpoint
    if os.path.exists(CHECKPOINT_PATH):
        print(f"✅ Resuming from: {CHECKPOINT_PATH}")
        model = YOLO(CHECKPOINT_PATH)
        model.train(resume=True)
    else:
        print("🆕 Starting fresh training...")
        model = YOLO(MODEL)
        
        # Minimal training parameters
        model.train(
            data=DATA,
            epochs=TOTAL_EPOCHS,
            imgsz=IMG_SIZE,
            batch=BATCH,
            name=NAME,
            workers=1,  # Minimal workers
            amp=False,  # Disable mixed precision
            verbose=True,
            patience=10
        )
    
    print("✅ Training completed!")
    
    # Simple validation
    try:
        model.val(data=DATA)
    except:
        print("⚠️  Validation skipped due to memory")

if __name__ == '__main__':
    main()