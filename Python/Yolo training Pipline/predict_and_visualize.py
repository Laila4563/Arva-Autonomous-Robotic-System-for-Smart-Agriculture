# predict_and_visualize.py
from ultralytics import YOLO
import cv2
from pathlib import Path

MODEL_PATH = 'runs/detect/plantvillage_yolov8n/weights/best.pt'  # adjust after training
IMAGES_DIR = Path('dataset/images/val')
OUT_DIR = Path('inference_out')
OUT_DIR.mkdir(exist_ok=True)

model = YOLO(MODEL_PATH)

for img_path in IMAGES_DIR.glob('*'):
    if img_path.suffix.lower() not in ['.jpg','.jpeg','.png']:
        continue
    results = model.predict(source=str(img_path), save=False, conf=0.25, imgsz=640)
    annotated = results[0].plot()
    out_path = OUT_DIR / img_path.name
    cv2.imwrite(str(out_path), annotated[:, :, ::-1])

print('Saved annotated images to', OUT_DIR)
