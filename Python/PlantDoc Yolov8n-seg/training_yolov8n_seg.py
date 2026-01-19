import torch
from ultralytics import YOLO

# --- Configuration ---
DATA_YAML = "./balanced_dataset/data.yaml"

class YOLOv8Trainer:
    def __init__(self, model_path, data_yaml, device):
        self.device = device
        self.model = YOLO(model_path) 
        self.data_yaml = data_yaml

    # This MUST be indented to be part of the class
    def train(self, epochs=75, imgsz=640): 
        train_args = {
            'data': self.data_yaml,
            'epochs': epochs,
            'imgsz': imgsz,
            'device': self.device,
            'task': 'segment',
            'batch': 8,
            'workers': 2,
            'patience': 35,       # Increased patience for late-stage refinement
            'cos_lr': True,
            
            # --- LOCALIZATION & ACCURACY IMPROVEMENTS ---
            'box': 10.0,          # Increased Box loss gain (default 7.5) to sharpen edges
            'cls': 2.0,           # Further increased classification weight
            'dropout': 0.15,      # Slight increase to force more robust feature learning
            'label_smoothing': 0.1, # Better generalization for overlapping classes
            
            # --- AUGMENTATION FOR COMPLEX BACKGROUNDS ---
            'mosaic': 1.0,        # 100% chance to combine images for scale awareness
            'mixup': 0.1,         # Blend images to handle overlapping leaves
            'flipud': 0.5,        # Random vertical flips (crucial for agriculture)
            'degrees': 15.0,      # Small rotations to handle camera angles
            'hsv_h': 0.015,       # Jitter hue to handle lighting differences
            'hsv_s': 0.7,         
            'hsv_v': 0.4,
            
            # --- STABILITY ---
            'amp': True,          # Use Mixed Precision for faster training if GPU supports it
            'overlap_mask': False # Helps with individual small leaf detection
        }
        print(f"🚀 Starting HIGH ACCURACY training on {self.device}...")
        self.model.train(**train_args)
    
        
        # --- PART ADDED TO PRINT METRICS ---#
        print("\n📊 Evaluating model performance...")
        metrics = self.model.val() # Runs validation
        
        print("\n" + "="*30)
        print("🏆 FINAL TRAINING METRICS")
        print("="*30)
        # Bounding Box Metrics
        print(f"Box mAP50:      {metrics.box.map50:.4f}")
        print(f"Box mAP50-95:   {metrics.box.map:.4f}")
        
        # Segmentation/Mask Metrics
        print(f"Mask mAP50:     {metrics.seg.map50:.4f}")
        print(f"Mask mAP50-95:  {metrics.seg.map:.4f}")
        print("="*30 + "\n")
        
        return self.model

if __name__ == "__main__":
    # Ensure CUDA is actually available for 'device=0'
    device = 0 if torch.cuda.is_available() else "cpu"
    print(f"✅ Training device: {device}")
    
    trainer = YOLOv8Trainer(model_path="yolov8n-seg.pt", data_yaml=DATA_YAML, device=device)
    
    # Keeping imgsz at 416 or 320 is highly recommended to avoid freezing your laptop
    model = trainer.train(epochs=75, imgsz=640)