import os
import shutil
import random

# -----------------------------
# CONFIG
# -----------------------------
SOURCE_DIR = r"C:\Users\20111\OneDrive\Desktop\Graduation\YOLO_correct\data\PlantVillage_for_object_detection\Dataset\images"
OUTPUT_DIR = "dataset_split_cls"

TRAIN_RATIO = 0.7
VAL_RATIO = 0.15
TEST_RATIO = 0.15

random.seed(42)

# -----------------------------
# CREATE OUTPUT FOLDERS
# -----------------------------
for split in ["train", "val", "test"]:
    os.makedirs(os.path.join(OUTPUT_DIR, split), exist_ok=True)

# -----------------------------
# GET CLASS FOLDERS
# -----------------------------
class_folders = [d for d in os.listdir(SOURCE_DIR)
                 if os.path.isdir(os.path.join(SOURCE_DIR, d))]

for cls in class_folders:
    src_cls_path = os.path.join(SOURCE_DIR, cls)
    imgs = [f for f in os.listdir(src_cls_path)
            if f.lower().endswith(('.jpg', '.png', '.jpeg'))]

    random.shuffle(imgs)

    n_total = len(imgs)
    n_train = int(n_total * TRAIN_RATIO)
    n_val = int(n_total * VAL_RATIO)

    train_imgs = imgs[:n_train]
    val_imgs = imgs[n_train:n_train + n_val]
    test_imgs = imgs[n_train + n_val:]

    # Make destination class folders
    for split in ["train", "val", "test"]:
        os.makedirs(os.path.join(OUTPUT_DIR, split, cls), exist_ok=True)

    # Copy
    for img in train_imgs:
        shutil.copy(os.path.join(src_cls_path, img),
                    os.path.join(OUTPUT_DIR, "train", cls, img))
    for img in val_imgs:
        shutil.copy(os.path.join(src_cls_path, img),
                    os.path.join(OUTPUT_DIR, "val", cls, img))
    for img in test_imgs:
        shutil.copy(os.path.join(src_cls_path, img),
                    os.path.join(OUTPUT_DIR, "test", cls, img))

print("✅ Classification dataset split complete!")
