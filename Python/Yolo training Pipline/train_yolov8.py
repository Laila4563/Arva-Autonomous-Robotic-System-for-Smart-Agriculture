# train_yolov8.py
from ultralytics import YOLO

MODEL = 'yolov8n.pt'  # you can switch to yolov8s.pt for better accuracy
DATA = 'dataset/dataset.yaml'
EPOCHS = 50
BATCH = 16
IMG_SIZE = 640
NAME = 'plantvillage_yolov8n'

if __name__ == '__main__':
    model = YOLO(MODEL)
    model.train(data=DATA, epochs=EPOCHS, imgsz=IMG_SIZE, batch=BATCH, name=NAME)
    print('Training finished. Check runs/ folder for logs and best.pt')