from ultralytics import YOLO
import torch

def main():
    print("CUDA available:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("Using GPU:", torch.cuda.get_device_name(0))

    model = YOLO("yolov8s.pt")

    model.train(
        data="data.yaml",          # IMPORTANT (no 'dataset/')
        epochs=50,
        imgsz=640,
        batch=16,
        device=0,
        name="pest_single_class",
        project="runs/train",
        # Optimization
        lr0=0.003,

        # Augmentations
        hsv_h=0.015,
        hsv_s=0.7,
        hsv_v=0.4,
        degrees=10.0,
        translate=0.1,
        scale=0.5,
        fliplr=0.5,
        mosaic=1.0,
        plots=True,                # loss curves, PR curves
        save=True
    )

    
    # Validation (metrics + confusion matrix)
    model.val(
        data="data.yaml",
        split="val",
        plots=True
    )

    # Test set evaluation
    model.val(
        data="data.yaml",
        split="test",
        plots=True
    )

if __name__ == "__main__":
    main()
