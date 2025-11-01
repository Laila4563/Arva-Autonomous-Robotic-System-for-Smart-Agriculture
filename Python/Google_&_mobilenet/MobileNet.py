import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision import datasets, transforms, models
from sklearn.metrics import (
    accuracy_score, precision_recall_fscore_support,
    confusion_matrix, classification_report
)
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path

# ==============================
#  CONFIGURATION
# ==============================
data_root = Path(r"C:\Users\20111\OneDrive\Desktop\Graduation\YOLO_correct\data\PlantVillage_for_object_detection\Dataset\mobilenet_dataset") # different path
model_path = Path(r"checkpoints\best_model.pth")  # <-- path to your saved model
batch_size = 32
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ==============================
#  DATA LOADING
# ==============================
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

train_data = datasets.ImageFolder(data_root / "train", transform=transform)
val_data = datasets.ImageFolder(data_root / "val", transform=transform)
test_data = datasets.ImageFolder(data_root / "test", transform=transform)

train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=False)
val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False)
test_loader = DataLoader(test_data, batch_size=batch_size, shuffle=False)

class_names = train_data.classes
num_classes = len(class_names)

# ==============================
#  LOAD MODEL
# ==============================
model = models.mobilenet_v2(pretrained=False)
model.classifier[1] = nn.Linear(model.last_channel, num_classes)
model.load_state_dict(torch.load(model_path, map_location=device))
model = model.to(device)
model.eval()

# ==============================
#  EVALUATION FUNCTION
# ==============================
def evaluate_split(model, loader, split_name, class_names):
    all_preds, all_labels = [], []
    with torch.no_grad():
        for imgs, labels in loader:
            imgs, labels = imgs.to(device), labels.to(device)
            outputs = model(imgs)
            preds = outputs.argmax(1)
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())

    acc = accuracy_score(all_labels, all_preds)
    precision, recall, f1, _ = precision_recall_fscore_support(all_labels, all_preds, average='weighted')
    report = classification_report(all_labels, all_preds, target_names=class_names)
    cm = confusion_matrix(all_labels, all_preds)

    print(f"\n {split_name} Results:")
    print(f"Accuracy:  {acc:.4f}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall:    {recall:.4f}")
    print(f"F1 Score:  {f1:.4f}")
    print("\nClassification Report:\n", report)

    plt.figure(figsize=(10, 8))
    sns.heatmap(cm, annot=False, fmt='d', cmap='Blues',
                xticklabels=class_names, yticklabels=class_names)
    plt.title(f"{split_name} Confusion Matrix")
    plt.xlabel("Predicted")
    plt.ylabel("True")
    plt.tight_layout()
    plt.show()

# ==============================
#  RUN EVALUATION
# ==============================
evaluate_split(model, train_loader, "Train", class_names)
evaluate_split(model, val_loader, "Validation", class_names)
evaluate_split(model, test_loader, "Test", class_names)
