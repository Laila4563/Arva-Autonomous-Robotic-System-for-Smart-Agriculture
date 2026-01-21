from ultralytics import YOLO
import torch

def main():
    use_cuda = torch.cuda.is_available()
    device = 0 if use_cuda else "cpu"

    print("CUDA available:", use_cuda)
    if use_cuda:
        print("Using GPU:", torch.cuda.get_device_name(0))

    # SEGMENTATION MODEL
    model = YOLO("yolov8s-seg.pt")

    model.train(
        data="data.yaml",
        epochs=50,
        imgsz=640,
        batch=8,              # 🔧 reduced for stability
        device=device,        # 🔧 GPU if available
        workers=0,            # 🔧 REQUIRED on Windows

        project="runs/segment",
        name="pest_single_class_seg",

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

        plots=True,           # loss curves, PR curves
        save=True
    )

    # Validation (VAL set)
    model.val(
        data="data.yaml",
        split="val",
        device=device,
        plots=True
    )

    # Test set evaluation (TEST set)
    model.val(
        data="data.yaml",
        split="test",
        device=device,
        plots=True
    )

if __name__ == "__main__":
    main()




