from ultralytics import YOLO
import torch

def main():
    print("CUDA available:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("Using GPU:", torch.cuda.get_device_name(0))

    # Load trained model (BEST weights)
    model = YOLO("runs/segment/unified_agri_seg/weights/best.pt")

    # Path to your test image (downloaded from Google)
    image_path = "test3.jpg"   # change if needed

    # Run inference
    results = model.predict(
        source=image_path,
        imgsz=640,
        conf=0.25,
        save=True,     # saves output image with boxes
        show=False     # set True to display window
    )

    print("Inference done. Check runs/predict/")

if __name__ == "__main__":
    main()
