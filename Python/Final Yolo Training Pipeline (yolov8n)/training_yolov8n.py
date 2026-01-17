import torch
from ultralytics import YOLO

# --- Configuration ---
DATA_YAML = "./balanced_dataset/data.yaml"

class YOLOv8Trainer:
    def __init__(self, model_path, data_yaml, device):
        self.device = device
        self.model = YOLO(model_path)
        self.data_yaml = data_yaml

    def train(self, epochs=50, imgsz=640):
        train_args = {
            'data': self.data_yaml,
            'epochs': epochs,
            'imgsz': imgsz,
            'device': self.device,
            'cos_lr': True,
            'patience': 50,
            'batch': -1, # Auto-batching
            'augment': True
        }
        print(f"🚀 Starting training on {self.data_yaml}...")
        self.model.train(**train_args)
        return self.model

if __name__ == "__main__":
    device = 0 if torch.cuda.is_available() else "cpu"
    print(f"✅ Training device: {device}")
    
    trainer = YOLOv8Trainer(model_path="yolov8n.pt", data_yaml=DATA_YAML, device=device)
    model = trainer.train(epochs=50, imgsz=640)