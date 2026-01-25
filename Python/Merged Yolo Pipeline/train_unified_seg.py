from ultralytics import YOLO
import torch
import json

def main():
    # -------------------------------------------------
    # DEVICE SETUP
    # -------------------------------------------------
    use_cuda = torch.cuda.is_available()
    device = 0 if use_cuda else "cpu"

    print("CUDA available:", use_cuda)
    if use_cuda:
        print("Using GPU:", torch.cuda.get_device_name(0))

    # -------------------------------------------------
    # LOAD YOLOv8 SEGMENTATION MODEL
    # -------------------------------------------------
    model = YOLO("yolov8s-seg.pt")

    # -------------------------------------------------
    # PATH TO DATA.YAML  (FIXED)
    # -------------------------------------------------
    DATA_YAML_PATH = "Merged Datasets/data.yaml"

    # -------------------------------------------------
    # TRAINING
    # -------------------------------------------------
    model.train(
        data=DATA_YAML_PATH,
        epochs=100,
        imgsz=640,
        batch=8,
        device=device,
        workers=0,  # REQUIRED ON WINDOWS

        project="runs/segment",
        name="unified_agri_seg",

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

        plots=True,
        save=True
    )

    # -------------------------------------------------
    # VALIDATION (VAL SET)
    # -------------------------------------------------
    print("\nRunning validation on VAL set...\n")
    val_results = model.val(
        data=DATA_YAML_PATH,
        split="val",
        device=device,
        plots=True
    )

    # -------------------------------------------------
    # TEST SET EVALUATION
    # -------------------------------------------------
    print("\nRunning evaluation on TEST set...\n")
    test_results = model.val(
        data=DATA_YAML_PATH,
        split="test",
        device=device,
        plots=True
    )

    # -------------------------------------------------
    # SAVE FINAL METRICS TO FILES
    # -------------------------------------------------
    print("\nSaving metrics to files...\n")

    # TXT summary
    with open("final_test_metrics.txt", "w") as f:
        f.write("FINAL TEST METRICS\n")
        f.write("==================\n\n")

        f.write("DETECTION (BOX) METRICS\n")
        f.write("----------------------\n")
        f.write(f"Precision: {test_results.box.mp}\n")
        f.write(f"Recall: {test_results.box.mr}\n")
        f.write(f"mAP50: {test_results.box.map50}\n")
        f.write(f"mAP50-95: {test_results.box.map}\n\n")

        f.write("SEGMENTATION (MASK) METRICS\n")
        f.write("--------------------------\n")
        f.write(f"Seg mAP50: {test_results.seg.map50}\n")
        f.write(f"Seg mAP50-95: {test_results.seg.map}\n")

    # JSON metrics (for analysis / plots)
    metrics = {
        "box": {
            "precision": test_results.box.mp,
            "recall": test_results.box.mr,
            "map50": test_results.box.map50,
            "map50_95": test_results.box.map
        },
        "segmentation": {
            "map50": test_results.seg.map50,
            "map50_95": test_results.seg.map
        }
    }

    with open("metrics.json", "w") as f:
        json.dump(metrics, f, indent=4)

    print("\nTRAINING + EVALUATION COMPLETED SUCCESSFULLY ✅")

if __name__ == "__main__":
    main()
