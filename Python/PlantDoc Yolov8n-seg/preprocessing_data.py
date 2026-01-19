import os
import cv2
import yaml
import random
import shutil
from glob import glob
from tqdm import tqdm
from matplotlib import pyplot as plt
from collections import defaultdict
from albumentations import (
    HorizontalFlip, VerticalFlip, 
    RandomBrightnessContrast, Compose, BboxParams,
    ShiftScaleRotate
)

# --- Configuration  ---
DATA_ROOT_PATH = "./plantDoc"  
OUTPUT_DIR = "./balanced_dataset"
DATA_TYPES = ["train", "valid", "test"]

def clean_working_directory():
    shutil.rmtree(OUTPUT_DIR, ignore_errors=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print("✅ Cleared and recreated necessary working directories.")

class EnhancedDataBalancer:
    def __init__(self, root, data_types, output_dir):
        self.root = root
        self.data_types = data_types
        self.output_dir = output_dir
        self.class_dict = {}
        self.analysis_data = defaultdict(dict)
        self._verify_and_create_paths()
        self._copy_config_file()
        self._load_class_names()
        self._copy_original_data()
        self._process_datasets()

    def _verify_and_create_paths(self):
        os.makedirs(self.output_dir, exist_ok=True)
        for dtype in self.data_types:
            os.makedirs(f"{self.output_dir}/{dtype}/images", exist_ok=True)
            os.makedirs(f"{self.output_dir}/{dtype}/labels", exist_ok=True)

    def _copy_config_file(self):
        src = f"{self.root}/data.yaml"
        dst = f"{self.output_dir}/data.yaml"
        if os.path.exists(src):
            shutil.copyfile(src, dst)
            print(f"✅ Copied config file to {dst}")
        else:
            raise FileNotFoundError(f"Missing critical config file: {src}")

    def _load_class_names(self):
        config_path = f"{self.output_dir}/data.yaml"
        try:
            with open(config_path) as f:
                data = yaml.safe_load(f)
            if isinstance(data.get('names'), dict):
                self.class_dict = {int(k): v for k, v in data['names'].items()}
            elif isinstance(data.get('names'), list):
                self.class_dict = {i: name for i, name in enumerate(data['names'])}
            
            data['path'] = os.path.abspath(self.output_dir)
            for dtype in self.data_types:
                data[dtype] = os.path.join(dtype, 'images')

            with open(config_path, 'w') as f:
                yaml.safe_dump(data, f)
            print(f"✅ Loaded {len(self.class_dict)} classes and updated data.yaml")
        except Exception as e:
            raise RuntimeError(f"Error loading class names: {str(e)}")

    def _copy_original_data(self):
        """Copies original data and ensures labels are converted to dummy polygons."""
        for dtype in self.data_types:
            src_images = glob(f"{self.root}/{dtype}/images/*")
            for img_path in tqdm(src_images, desc=f"Converting {dtype} to Seg Format"):
                # Copy Image
                img_name = os.path.basename(img_path)
                shutil.copy(img_path, f"{self.output_dir}/{dtype}/images/{img_name}")
                
                # Convert Label
                label_path = img_path.replace("images", "labels").rsplit('.', 1)[0] + '.txt'
                if os.path.exists(label_path):
                    self._convert_and_save_label(label_path, f"{self.output_dir}/{dtype}/labels/{img_name.replace('.jpg', '.txt')}")

    def _convert_and_save_label(self, src, dst):
        """Helper to convert box labels to 4-point polygon labels."""
        with open(src, 'r') as f:
            lines = f.readlines()
        with open(dst, 'w') as f:
            for line in lines:
                parts = list(map(float, line.strip().split()))
                if len(parts) == 5: # It's a box: [cls, x, y, w, h]
                    cls, xc, yc, w, h = parts
                    # Create 4-point polygon (rectangular mask)
                    x1, y1 = xc - w/2, yc - h/2
                    x2, y2 = xc + w/2, yc - h/2
                    x3, y3 = xc + w/2, yc + h/2
                    x4, y4 = xc - w/2, yc + h/2
                    f.write(f"{int(cls)} {x1:.6f} {y1:.6f} {x2:.6f} {y2:.6f} {x3:.6f} {y3:.6f} {x4:.6f} {y4:.6f}\n")
                elif len(parts) > 5: # Already a polygon
                    f.write(line)

    def _process_datasets(self):
        for dtype in self.data_types:
            class_counter = defaultdict(int)
            image_dir = f"{self.output_dir}/{dtype}/images"
            for img_path in tqdm(glob(f"{image_dir}/*"), desc=f"Analyzing {dtype}"):
                label_path = img_path.replace("images", "labels").rsplit('.', 1)[0] + '.txt'
                if not os.path.exists(label_path): continue
                with open(label_path) as f:
                    lines = [line.strip() for line in f.readlines() if line.strip()]
                present_classes = set()
                for line in lines:
                    parts = line.split()
                    if len(parts) >= 5: 
                        class_id = int(float(parts[0]))
                        if class_id in self.class_dict:
                            present_classes.add(self.class_dict[class_id])
                for cls in present_classes:
                    class_counter[cls] += 1
            self.analysis_data[dtype] = dict(class_counter)

    def analyze_balance(self):
        for dtype in self.data_types:
            self._plot_distribution(dtype, "Original Distribution", self.analysis_data[dtype], '#2ecc71')

    def balance_strategy(self, augmentation_factor=1.5):
        self.augmentor = AdvancedAugmentor(self.root, self.output_dir, self.class_dict)
        for dtype in self.data_types:
            if dtype != 'train': continue
            total = len(glob(f"{self.output_dir}/{dtype}/images/*"))
            num_classes = len(self.class_dict)
            if num_classes == 0 or total == 0: continue
            avg = total / num_classes
            target_counts = {cls: int(avg * augmentation_factor) for cls in self.class_dict.values()}
            self.augmentor.augment_dataset(dtype, target_counts, self.analysis_data[dtype])

    def analyze_balanced_data(self):
        for dtype in self.data_types:
            balanced_image_dir = f"{self.output_dir}/{dtype}/images"
            class_counter = defaultdict(int)
            for img_path in glob(f"{balanced_image_dir}/*"):
                label_path = img_path.replace("images", "labels").rsplit('.', 1)[0] + '.txt'
                if not os.path.exists(label_path): continue
                with open(label_path, 'r') as f:
                    lines = [line.strip() for line in f.readlines() if line.strip()]
                present_classes = set()
                for line in lines:
                    parts = line.split()
                    if len(parts) >= 5:
                        class_id = int(float(parts[0]))
                        if class_id in self.class_dict:
                            present_classes.add(self.class_dict[class_id])
                for cls in present_classes:
                    class_counter[cls] += 1
            self._plot_distribution(dtype, "Balanced Distribution", class_counter, '#3498db')

    def _plot_distribution(self, dtype, title, class_counter, color):
        classes = sorted(class_counter.keys())
        counts = [class_counter[cls] for cls in classes]
        plt.figure(figsize=(12, 6))
        plt.bar(classes, counts, color=color)
        plt.title(f"{dtype.upper()} - {title}")
        plt.xticks(rotation=45, ha='right')
        plt.tight_layout()
        plt.show()

class AdvancedAugmentor:
    def __init__(self, root, output_dir, class_dict):
        self.root = root
        self.output_dir = output_dir
        self.class_dict = class_dict
        self.strong_aug = Compose([
            HorizontalFlip(p=0.5), VerticalFlip(p=0.3),
            ShiftScaleRotate(shift_limit=0.1, scale_limit=0.2, rotate_limit=30, p=0.8),
            RandomBrightnessContrast(p=0.5)
        ], bbox_params=BboxParams(format='yolo', label_fields=['class_labels']))

    def augment_dataset(self, dtype, target_counts, current_counts):
        original_images = glob(f"{self.root}/{dtype}/images/*")
        for class_name, target_count in target_counts.items():
            current_count = current_counts.get(class_name, 0)
            if current_count < target_count:
                needed = target_count - current_count
                class_images = [img for img in original_images if self._has_class(img, class_name)]
                if not class_images: continue
                for i in tqdm(range(needed), desc=f"Augmenting {class_name}"):
                    img_path = random.choice(class_images)
                    label_path = img_path.replace("images", "labels").rsplit('.', 1)[0] + '.txt'
                    image = cv2.cvtColor(cv2.imread(img_path), cv2.COLOR_BGR2RGB)
                    with open(label_path) as f:
                        lines = [line.strip() for line in f.readlines() if line.strip()]
                    bboxes, class_ids = [], []
                    for line in lines:
                        parts = list(map(float, line.split()))
                        class_ids.append(int(parts[0]))
                        # Ensure we only use first 4 coords for Albumentations logic
                        bboxes.append(parts[1:5]) 
                    transformed = self.strong_aug(image=image, bboxes=bboxes, class_labels=class_ids)
                    self._save_data(transformed['image'], transformed['bboxes'], transformed['class_labels'], img_path, dtype, i)

    def _has_class(self, img_path, target_class):
        label_path = img_path.replace("images", "labels").rsplit('.', 1)[0] + '.txt'
        try:
            with open(label_path) as f:
                lines = f.readlines()
            for line in lines:
                if self.class_dict.get(int(line.split()[0])) == target_class: return True
            return False
        except: return False

    def _save_data(self, image, bboxes, class_ids, original_path, dtype, aug_index):
        base_name = os.path.basename(original_path).rsplit('.', 1)[0]
        new_name = f"aug_{aug_index:03d}_{base_name}.jpg"
        cv2.imwrite(os.path.join(self.output_dir, dtype, "images", new_name), cv2.cvtColor(image, cv2.COLOR_RGB2BGR))
        with open(os.path.join(self.output_dir, dtype, "labels", new_name.replace(".jpg", ".txt")), 'w') as f:
            for cls_id, bbox in zip(class_ids, bboxes):
                xc, yc, w, h = bbox
                # Convert augmented box back to dummy 4-point polygon
                x1, y1 = xc - w/2, yc - h/2
                x2, y2 = xc + w/2, yc - h/2
                x3, y3 = xc + w/2, yc + h/2
                x4, y4 = xc - w/2, yc + h/2
                f.write(f"{int(cls_id)} {x1:.6f} {y1:.6f} {x2:.6f} {y2:.6f} {x3:.6f} {y3:.6f} {x4:.6f} {y4:.6f}\n")

if __name__ == "__main__":
    clean_working_directory()
    balancer = EnhancedDataBalancer(DATA_ROOT_PATH, DATA_TYPES, OUTPUT_DIR)
    balancer.analyze_balance()
    balancer.balance_strategy(augmentation_factor=1.5)
    balancer.analyze_balanced_data()