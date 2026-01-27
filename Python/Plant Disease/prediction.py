import os
from ultralytics import YOLO

# --- Configuration ---
# YOLOv8 saves to 'runs/segment/train' by default. 
# If you ran it multiple times, it might be 'train2', 'train3', etc.
WEIGHTS_PATH = "./runs/segment/train/weights/best.pt" 

# Folder containing your unseen images
INPUT_FOLDER_PATH = "./Unseen Images For Prediction" 

def run_prediction():
    # 1. Verification of weights
    if not os.path.exists(WEIGHTS_PATH):
        print(f"❌ Error: Weights not found at {WEIGHTS_PATH}.")
        print("💡 Check your 'runs/segment' folder to see if the folder name is 'train2' or 'train3' and update WEIGHTS_PATH.")
        return

    # 2. Verification of input folder
    if not os.path.exists(INPUT_FOLDER_PATH):
        # Create it if it doesn't exist so the user can just drop images in
        os.makedirs(INPUT_FOLDER_PATH, exist_ok=True)
        print(f"📁 Created empty folder at {INPUT_FOLDER_PATH}. Please add images and run again.")
        return

    # 3. Load the YOLOv8-seg model
    try:
        model = YOLO(WEIGHTS_PATH)
        print(f"✅ Loaded Segmentation Model: {WEIGHTS_PATH}")
    except Exception as e:
        print(f"❌ Failed to load model: {e}")
        return

    print(f"🔍 Processing images in: {INPUT_FOLDER_PATH}")

    # 4. Run Prediction
    # We use task='segment' to ensure masks are generated
    results = model.predict(
        source=INPUT_FOLDER_PATH,
        conf=0.40,      # Lowered slightly to catch more potential diseases
        iou=0.45,
        imgsz=640,      # Match the training size for best accuracy and laptop stability
        augment=True,        # <--- KEY: Test-Time Augmentation for accuracy
        retina_masks=True,
        save=True,      # Saves annotated images to runs/predict/segmentation_results
        save_txt=True,  # Saves the prediction coordinates (useful for debugging)
        project='runs/predict', 
        name='segmentation_results for train',
        exist_ok=True,  # Overwrites the folder instead of creating 'segmentation_results2'
        device=0        # Uses GPU for fast prediction
    )

    print(f"\n✅ Batch inference complete.")
    print(f"📂 Annotated images saved to: ./runs/predict/segmentation_results")

if __name__ == "__main__":
    run_prediction()