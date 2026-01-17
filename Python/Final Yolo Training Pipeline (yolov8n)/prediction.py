import os
from ultralytics import YOLO

# --- Configuration ---
# Path to your best trained weights
WEIGHTS_PATH = "./runs/detect/train2/weights/best.pt"

# Update this to the folder containing your unseen images
INPUT_FOLDER_PATH = "./Unseen Images For Prediction" 

def run_prediction():
    # 1. Check if weights exist
    if not os.path.exists(WEIGHTS_PATH):
        print(f"❌ Error: Weights not found at {WEIGHTS_PATH}. Did training finish?")
        return

    # 2. Check if the input folder exists
    if not os.path.exists(INPUT_FOLDER_PATH):
        print(f"❌ Error: Input folder not found at {INPUT_FOLDER_PATH}. Please create it and add images.")
        return

    # Load model
    model = YOLO(WEIGHTS_PATH)
    print(f"✅ Loaded model: {WEIGHTS_PATH}")
    print(f"🔍 Processing images in: {INPUT_FOLDER_PATH}")

    # Run prediction on the whole folder
    # YOLO automatically finds all images in the directory
    results = model.predict(
        source=INPUT_FOLDER_PATH,
        conf=0.45,
        imgsz=640,
        augment=True,
        save=True,  # Saves annotated images to the project folder
        project='runs/predict', 
        name='folder_prediction_results',
        exist_ok=True # Overwrites the folder if it already exists instead of creating 'name2'
    )

    print(f"✅ Batch inference complete.")
    print(f"📂 Results saved to: ./runs/predict/folder_prediction_results")

if __name__ == "__main__":
    run_prediction()