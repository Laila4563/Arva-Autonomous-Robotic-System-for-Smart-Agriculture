import os
import yaml

BASE_DIR = "./plantDoc"
SPLITS = ["train", "valid", "test"]

# --------- ORIGINAL CLASSES ----------
original_classes = [
    "Apple Scab Leaf",
    "Apple leaf",
    "Apple rust leaf",
    "Bell_pepper leaf spot",
    "Bell_pepper leaf",
    "Blueberry leaf",
    "Cherry leaf",
    "Corn Gray leaf spot",
    "Corn leaf blight",
    "Corn rust leaf",
    "Peach leaf",
    "Potato leaf early blight",
    "Potato leaf late blight",
    "Potato leaf",
    "Raspberry leaf",
    "Soyabean leaf",
    "Soybean leaf",
    "Squash Powdery mildew leaf",
    "Strawberry leaf",
    "Tomato Early blight leaf",
    "Tomato Septoria leaf spot",
    "Tomato leaf bacterial spot",
    "Tomato leaf late blight",
    "Tomato leaf mosaic virus",
    "Tomato leaf yellow virus",
    "Tomato leaf",
    "Tomato mold leaf",
    "Tomato two spotted spider mites leaf",
    "grape leaf black rot",
    "grape leaf"
]

# --------- REMOVE THESE ----------
remove_classes = {
    "Apple rust leaf",
    "Corn Gray leaf spot",
    "Corn rust leaf",
    "Potato leaf early blight",
    "Tomato two spotted spider mites leaf",
    "Tomato leaf yellow virus",
    "Tomato Early blight leaf",
     "Tomato leaf mosaic virus",
    "Tomato Septoria leaf spot",
    "Tomato leaf late blight",
    "Tomato leaf bacterial spot",
    "Blueberry leaf",
    "Cherry leaf",
    "Peach leaf",
    "Raspberry leaf",
    "Soyabean leaf",
    "Soybean leaf"
    
}

# --------- BUILD MAPPINGS ----------
keep_classes = [c for c in original_classes if c not in remove_classes]

old_to_new = {}
new_index = 0
for i, name in enumerate(original_classes):
    if name in keep_classes:
        old_to_new[i] = new_index
        new_index += 1

remove_ids = {i for i, name in enumerate(original_classes) if name in remove_classes}

# --------- REMOVE IMAGES & LABELS ----------
for split in SPLITS:
    labels_dir = os.path.join(BASE_DIR, split, "labels")
    images_dir = os.path.join(BASE_DIR, split, "images")

    for label_file in os.listdir(labels_dir):
        label_path = os.path.join(labels_dir, label_file)

        with open(label_path, "r") as f:
            lines = f.readlines()

        delete = False
        for line in lines:
            class_id = int(line.split()[0])
            if class_id in remove_ids:
                delete = True
                break

        if delete:
            os.remove(label_path)
            img = label_file.replace(".txt", ".jpg")
            img_path = os.path.join(images_dir, img)
            if os.path.exists(img_path):
                os.remove(img_path)
            continue

        # rewrite label with new ids
        new_lines = []
        for line in lines:
            parts = line.split()
            parts[0] = str(old_to_new[int(parts[0])])
            new_lines.append(" ".join(parts))

        with open(label_path, "w") as f:
            f.write("\n".join(new_lines))

# --------- WRITE NEW data.yaml ----------
data_yaml = {
    "train": "../train/images",
    "val": "../valid/images",
    "test": "../test/images",
    "nc": len(keep_classes),
    "names": keep_classes
}

with open(os.path.join(BASE_DIR, "data.yaml"), "w") as f:
    yaml.dump(data_yaml, f, sort_keys=False)

print("✅ Dataset cleaned successfully")
print(f"✅ Classes kept: {len(keep_classes)}")
