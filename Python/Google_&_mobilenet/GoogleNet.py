import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision import datasets, transforms, models
from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    confusion_matrix,
    classification_report
)
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
from tqdm import tqdm

def train_googlenet(data_root, epochs=10, batch_size=32, lr=1e-4, save_dir="checkpoints"):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    data_root = Path(data_root)
    transform_train = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406],
                             [0.229, 0.224, 0.225])
    ])
    transform_test = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406],
                             [0.229, 0.224, 0.225])
    ])

    # Dataset loaders
    train_data = datasets.ImageFolder(data_root / "train", transform=transform_train)
    val_data = datasets.ImageFolder(data_root / "val", transform=transform_test)
    test_data = datasets.ImageFolder(data_root / "test", transform=transform_test)

    train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False)
    test_loader = DataLoader(test_data, batch_size=batch_size, shuffle=False)

    num_classes = len(train_data.classes)
    print(f"Number of classes: {num_classes}")

    # GoogLeNet setup
    model = models.googlenet(weights=models.GoogLeNet_Weights.DEFAULT)
    model.fc = nn.Linear(1024, num_classes)
    model = model.to(device)

    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)

    best_acc = 0
    save_dir = Path(save_dir)
    save_dir.mkdir(parents=True, exist_ok=True)

    for epoch in range(epochs):
        model.train()
        total_loss, total_correct = 0, 0
        for imgs, labels in tqdm(train_loader, desc=f"Epoch {epoch+1}/{epochs}"):
            imgs, labels = imgs.to(device), labels.to(device)
            optimizer.zero_grad()
            outputs = model(imgs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            total_loss += loss.item() * imgs.size(0)
            total_correct += (outputs.argmax(1) == labels).sum().item()

        train_acc = total_correct / len(train_loader.dataset)
        val_acc = evaluate(model, val_loader, device)
        print(f"Epoch {epoch+1}: Train Acc={train_acc:.4f}, Val Acc={val_acc:.4f}")

        if val_acc > best_acc:
            best_acc = val_acc
            torch.save(model.state_dict(), save_dir / "googlenet_best.pth")

    print("\nTraining complete. Best Validation Accuracy:", best_acc)
    print("="*80)

    # Evaluate all splits
    print("\n TRAIN SET METRICS")
    evaluate_metrics(model, train_loader, device, class_names=train_data.classes, split_name="Train")

    print("\n VALIDATION SET METRICS")
    evaluate_metrics(model, val_loader, device, class_names=val_data.classes, split_name="Validation")

    print("\n TEST SET METRICS")
    evaluate_metrics(model, test_loader, device, class_names=test_data.classes, split_name="Test")

def evaluate(model, loader, device):
    model.eval()
    correct = 0
    with torch.no_grad():
        for imgs, labels in loader:
            imgs, labels = imgs.to(device), labels.to(device)
            outputs = model(imgs)
            preds = outputs.argmax(1)
            correct += (preds == labels).sum().item()
    return correct / len(loader.dataset)

def evaluate_metrics(model, loader, device, class_names, split_name=""):
    model.eval()
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
    cm = confusion_matrix(all_labels, all_preds)
    report = classification_report(all_labels, all_preds, target_names=class_names)

    # Print summary
    print(f"{split_name} Accuracy:  {acc:.4f}")
    print(f"{split_name} Precision: {precision:.4f}")
    print(f"{split_name} Recall:    {recall:.4f}")
    print(f"{split_name} F1 Score:  {f1:.4f}")
    print("\nClassification Report:\n")
    print(report)

    # Plot confusion matrix
    plt.figure(figsize=(10, 8))
    sns.heatmap(cm, annot=False, fmt='d', cmap='Blues',
                xticklabels=class_names, yticklabels=class_names)
    plt.title(f"{split_name} Confusion Matrix")
    plt.xlabel("Predicted")
    plt.ylabel("True")
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    train_googlenet(
        data_root=r"C:\Users\20111\OneDrive\Desktop\Graduation\YOLO_correct\data\PlantVillage_for_object_detection\Dataset\mobilenet_dataset",
        epochs=10,
        batch_size=32,
        lr=1e-4
    )
