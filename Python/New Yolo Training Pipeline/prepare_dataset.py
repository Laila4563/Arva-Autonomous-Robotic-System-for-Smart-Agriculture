import os
import shutil
import cv2
import numpy as np
from pathlib import Path
from sklearn.model_selection import train_test_split
import albumentations as A
import yaml

ROOT = Path('data')
OUT = Path('dataset2')
OUT_IMAGES = OUT / 'images'
OUT_LABELS = OUT / 'labels'
RANDOM_STATE = 42

IMAGE_EXTS = {'.jpg', '.jpeg', '.png', '.bmp'}

def get_agricultural_augmentation_pipeline():
    """Augmentation pipeline optimized for real-world agricultural environments"""
    return A.Compose([
        # === LIGHTING VARIATIONS (Field Conditions) ===
        # Bright sunlight to overcast conditions
        A.RandomBrightnessContrast(
            brightness_limit=(-0.3, 0.4),  # Dark shadows to bright sun
            contrast_limit=(-0.2, 0.3), 
            p=0.8
        ),
        
        # Sun angle and color temperature changes
        A.HueSaturationValue(
            hue_shift_limit=10,      # Slight color shifts from morning to afternoon light
            sat_shift_limit=(-20, 30), # Vivid colors in bright light, washed in overcast
            val_shift_limit=(-20, 20),
            p=0.7
        ),
        
        # Haze and atmospheric conditions
        A.RandomGamma(gamma_limit=(80, 140), p=0.4),  # Different exposure conditions
        
        # === WEATHER AND ENVIRONMENTAL EFFECTS ===
        # Rain and moisture effects
        A.RandomRain(
            slant_lower=-10, 
            slant_upper=10, 
            drop_length=20, 
            drop_width=1, 
            drop_color=(200, 200, 200), 
            blur_value=1, 
            brightness_coefficient=0.9, 
            p=0.1
        ),
        
        # Lens effects and light artifacts
        A.RandomSunFlare(
            flare_roi=(0, 0, 1, 0.5), 
            angle_lower=0.1, 
            angle_upper=0.5, 
            num_flare_circles_lower=2, 
            num_flare_circles_upper=4, 
            src_radius=300, 
            src_color=(255, 255, 255), 
            p=0.05
        ),
        
        # === PLANT-SPECIFIC TRANSFORMATIONS ===
        # Leaf movement and plant deformation
        A.ElasticTransform(
            alpha=50, 
            sigma=120, 
            alpha_affine=50, 
            p=0.3
        ),
        
        # Wind effects (mild distortion)
        A.OpticalDistortion(
            distort_limit=0.1, 
            shift_limit=0.05, 
            p=0.2
        ),
        
        # === CAMERA AND CAPTURE VARIATIONS ===
        # Different focus conditions
        A.GaussianBlur(
            blur_limit=(1, 5),  # Slight blur from wind or camera movement
            p=0.4
        ),
        
        # Camera noise and grain
        A.GaussNoise(
            var_limit=(5.0, 30.0), 
            p=0.3
        ),
        
        # Vignetting effect (common in field cameras)
        A.RandomShadow(
            shadow_roi=(0, 0.5, 1, 1), 
            num_shadows_lower=1, 
            num_shadows_upper=2, 
            shadow_dimension=5, 
            p=0.2
        ),
        
        # === PERSPECTIVE AND VIEWPOINT CHANGES ===
        # Robot/camera angle variations
        A.Perspective(
            scale=(0.05, 0.15),  # Slight perspective changes
            keep_size=True, 
            p=0.4
        ),
        
        # Camera height variations
        A.Affine(
            scale=(0.9, 1.1),      # Zoom variations
            translate_percent=(-0.1, 0.1),  # Position variations
            rotate=(-10, 10),      # Rotation from different angles
            shear=(-5, 5),         # Mild shear
            p=0.6
        ),
        
        # === OCCLUSIONS AND FIELD OBSTRUCTIONS ===
        # Partial leaf occlusions
        A.CoarseDropout(
            max_holes=8, 
            max_height=0.1,  # Relative to image height
            max_width=0.1,   # Relative to image width
            min_holes=1, 
            min_height=0.03, 
            min_width=0.03, 
            fill_value=0, 
            p=0.3
        ),
        
        # Soil and debris spots
       A.Spatter(p=0.15),

        
        # === SEASONAL AND TIME-BASED VARIATIONS ===
        # Color temperature changes (morning vs afternoon)
        A.ColorJitter(
            brightness=0.1, 
            contrast=0.1, 
            saturation=0.1, 
            hue=0.05, 
            p=0.4
        ),
        
        # Early morning dew/frost effects
        A.RandomFog(
            fog_coef_lower=0.01, 
            fog_coef_upper=0.1, 
            alpha_coef=0.08, 
            p=0.05
        ),
        
    ], bbox_params=A.BboxParams(
        format='yolo', 
        label_fields=['class_labels'],
        min_visibility=0.3,  # Ensure boxes are still reasonably visible
        min_area=16          # Minimum area in pixels
    ))


def get_advanced_agricultural_augmentations():
    """More specialized augmentations for challenging agricultural conditions"""
    return A.OneOf([
        # Heavy rain conditions
        A.Compose([
            A.RandomRain(p=1.0),
            A.RandomBrightnessContrast(brightness_limit=-0.3, contrast_limit=-0.1, p=1.0),
            A.GaussianBlur(blur_limit=3, p=0.8),
        ], p=0.1),
        
        # Bright midday sun
        A.Compose([
            A.RandomBrightnessContrast(brightness_limit=0.4, contrast_limit=0.3, p=1.0),
            A.RandomSunFlare(p=0.3),
            A.HueSaturationValue(sat_shift_limit=20, p=0.7),
        ], p=0.15),
        
        # Overcast conditions
        A.Compose([
            A.RandomBrightnessContrast(brightness_limit=-0.2, contrast_limit=-0.2, p=1.0),
            A.CLAHE(clip_limit=2.0, p=0.5),
            A.GaussianBlur(blur_limit=2, p=0.3),
        ], p=0.15),
        
        # Early morning/late afternoon
        A.Compose([
            A.HueSaturationValue(hue_shift_limit=10, sat_shift_limit=-10, p=1.0),
            A.RandomGamma(gamma_limit=(60, 100), p=0.7),
        ], p=0.1),
        
        # Windy conditions
        A.Compose([
            A.ElasticTransform(alpha=80, sigma=150, p=1.0),
            A.MotionBlur(blur_limit=5, p=0.6),
        ], p=0.1),
        
        # Default augmentation (mild conditions)
        A.Compose([
            A.RandomBrightnessContrast(brightness_limit=0.2, contrast_limit=0.2, p=0.8),
            A.Affine(rotate=(-5, 5), scale=(0.95, 1.05), p=0.6),
        ], p=0.4),
        
    ], p=1.0)


def parse_yolo_label(label_path):
    """Parse YOLO format labels"""
    if not label_path.exists():
        return [], []
    
    bboxes = []
    class_labels = []
    
    with open(label_path, 'r') as f:
        for line in f:
            if line.strip():
                parts = line.strip().split()
                if len(parts) >= 5:
                    class_id = int(parts[0])
                    x_center, y_center, width, height = map(float, parts[1:5])
                    bboxes.append([x_center, y_center, width, height])
                    class_labels.append(class_id)
    
    return bboxes, class_labels


def validate_bbox(bbox, img_width, img_height):
    """Validate and fix bounding box coordinates with pixel-based validation"""
    x_center, y_center, width, height = bbox
    
    # Convert to pixel coordinates for validation
    x_center_px = x_center * img_width
    y_center_px = y_center * img_height
    width_px = width * img_width
    height_px = height * img_height
    
    # Calculate pixel bounds
    x_min_px = max(0, x_center_px - width_px / 2)
    y_min_px = max(0, y_center_px - height_px / 2)
    x_max_px = min(img_width, x_center_px + width_px / 2)
    y_max_px = min(img_height, y_center_px + height_px / 2)
    
    # Ensure minimum size (at least 4x4 pixels)
    if (x_max_px - x_min_px) < 4 or (y_max_px - y_min_px) < 4:
        return None
    
    # Convert back to normalized coordinates
    new_x_center = (x_min_px + x_max_px) / (2 * img_width)
    new_y_center = (y_min_px + y_max_px) / (2 * img_height)
    new_width = (x_max_px - x_min_px) / img_width
    new_height = (y_max_px - y_min_px) / img_height
    
    # Ensure reasonable size
    if new_width < 0.01 or new_height < 0.01:
        return None
    
    return [new_x_center, new_y_center, new_width, new_height]


def process_agricultural_batch(images_batch, labels_batch, output_images_dir, output_labels_dir, augmentations_per_image=2):
    """Process batch with agricultural-specific augmentations"""
    base_augmentation = get_agricultural_augmentation_pipeline()
    advanced_augmentation = get_advanced_agricultural_augmentations()
    
    augmented_count = 0
    
    for img_path, label_path in zip(images_batch, labels_batch):
        # Load image and labels
        image = cv2.imread(str(img_path))
        if image is None:
            continue
            
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        img_height, img_width = image_rgb.shape[:2]
        bboxes, class_labels = parse_yolo_label(label_path)
        
        if not bboxes:
            continue
        
        # Apply multiple augmentations
        for aug_idx in range(augmentations_per_image):
            try:
                # Choose augmentation strategy
                if np.random.random() < 0.3:  # 30% chance for advanced augmentations
                    augmentation = advanced_augmentation
                else:
                    augmentation = base_augmentation
                
                # Apply augmentation
                transformed = augmentation(image=image_rgb, bboxes=bboxes, class_labels=class_labels)
                aug_image = transformed['image']
                aug_bboxes = transformed['bboxes']
                aug_class_labels = transformed['class_labels']
                
                # Validate and filter bounding boxes
                valid_bboxes = []
                valid_labels = []
                
                for bbox, label in zip(aug_bboxes, aug_class_labels):
                    valid_bbox = validate_bbox(bbox, img_width, img_height)
                    if valid_bbox is not None:
                        valid_bboxes.append(valid_bbox)
                        valid_labels.append(label)
                
                if not valid_bboxes:
                    continue
                
                # Save augmented image
                aug_img_name = f"{img_path.stem}_field_aug{aug_idx}.jpg"
                aug_img_path = output_images_dir / aug_img_name
                cv2.imwrite(str(aug_img_path), cv2.cvtColor(aug_image, cv2.COLOR_RGB2BGR))
                
                # Save augmented labels
                aug_label_path = output_labels_dir / f"{img_path.stem}_field_aug{aug_idx}.txt"
                with open(aug_label_path, 'w') as f:
                    for bbox, class_id in zip(valid_bboxes, valid_labels):
                        f.write(f"{class_id} {bbox[0]:.6f} {bbox[1]:.6f} {bbox[2]:.6f} {bbox[3]:.6f}\n")
                
                augmented_count += 1
                
            except Exception as e:
                # Continue with next augmentation even if one fails
                continue
    
    return augmented_count


def inspect_data_structure(root):
    """Quick data inspection"""
    img_files = list(root.rglob('*.*'))
    images = [p for p in img_files if p.suffix.lower() in IMAGE_EXTS]
    labels = [p for p in img_files if p.suffix.lower() == '.txt']
    
    print(f"Found {len(images)} images, {len(labels)} labels")
    
    # Show class distribution if available
    class_dist = {}
    for label_file in labels[:1000]:  # Sample first 1000 labels
        try:
            with open(label_file, 'r') as f:
                for line in f:
                    if line.strip():
                        class_id = int(line.split()[0])
                        class_dist[class_id] = class_dist.get(class_id, 0) + 1
        except:
            continue
    
    if class_dist:
        print("Class distribution sample:")
        for class_id, count in sorted(class_dist.items()):
            print(f"  Class {class_id}: {count} instances")
    
    return len(images)


def find_images_and_labels(root):
    """Find all images and their corresponding labels"""
    images = []
    for p in root.rglob('*'):
        if p.suffix.lower() in IMAGE_EXTS:
            images.append(p)
    
    mapping = {}
    for img_path in images:
        label_path = img_path.with_suffix('.txt')
        if not label_path.exists():
            # Check in labels folder
            label_path = root / 'labels' / f"{img_path.stem}.txt"
        
        if label_path.exists():
            mapping[str(img_path)] = str(label_path)
        else:
            mapping[str(img_path)] = None
    
    return mapping


def prepare_agricultural_dataset(mapping, augmentations_per_image=2, batch_size=500):
    """Main function to prepare dataset with agricultural-specific augmentations"""
    # Create output directories
    if OUT.exists():
        shutil.rmtree(OUT)
    
    for split in ['train', 'val', 'test']:
        (OUT_IMAGES / split).mkdir(parents=True, exist_ok=True)
        (OUT_LABELS / split).mkdir(parents=True, exist_ok=True)
    
    # Split data
    img_paths = list(mapping.keys())
    train_val, test = train_test_split(img_paths, test_size=0.1, random_state=RANDOM_STATE)
    train, val = train_test_split(train_val, test_size=0.1, random_state=RANDOM_STATE)
    
    splits = {
        'train': train,
        'val': val, 
        'test': test
    }
    
    # Process each split
    for split_name, split_paths in splits.items():
        print(f"\nProcessing {split_name} set ({len(split_paths)} images)...")
        
        # Copy original files
        for img_path in split_paths:
            img = Path(img_path)
            label_path = Path(mapping[img_path])
            
            # Copy image
            dst_img = OUT_IMAGES / split_name / img.name
            shutil.copy2(img, dst_img)
            
            # Copy label
            if label_path.exists():
                dst_label = OUT_LABELS / split_name / label_path.name
                shutil.copy2(label_path, dst_label)
        
        # Apply agricultural-specific augmentation only to training set
        if split_name == 'train' and augmentations_per_image > 0:
            print(f"Applying agricultural augmentations to {split_name} set...")
            
            # Get all training images and labels
            train_images = [OUT_IMAGES / 'train' / Path(p).name for p in split_paths]
            train_labels = [OUT_LABELS / 'train' / Path(mapping[p]).name for p in split_paths]
            
            # Filter valid pairs
            valid_pairs = [(img, lbl) for img, lbl in zip(train_images, train_labels) if lbl.exists()]
            valid_images = [pair[0] for pair in valid_pairs]
            valid_labels = [pair[1] for pair in valid_pairs]
            
            # Process in batches
            total_augmented = 0
            for i in range(0, len(valid_images), batch_size):
                batch_images = valid_images[i:i + batch_size]
                batch_labels = valid_labels[i:i + batch_size]
                
                batch_augmented = process_agricultural_batch(
                    batch_images, batch_labels,
                    OUT_IMAGES / 'train',
                    OUT_LABELS / 'train',
                    augmentations_per_image
                )
                total_augmented += batch_augmented
                print(f"  Batch {i//batch_size + 1}: {batch_augmented} augmented images")
            
            print(f"Total agricultural-augmented images: {total_augmented}")
        
        print(f"Completed {split_name} set")
    
    return len(train), len(val), len(test)


def diagnose_classes():
    """Check what classes are actually in the dataset"""
    print("🔍 Diagnosing dataset classes...")
    
    class_counts = {}
    for split in ['train', 'val', 'test']:
        split_dir = OUT_LABELS / split
        if split_dir.exists():
            for label_file in split_dir.rglob('*.txt'):
                try:
                    with open(label_file, 'r') as f:
                        for line in f:
                            if line.strip():
                                class_id = int(line.split()[0])
                                class_counts[class_id] = class_counts.get(class_id, 0) + 1
                except Exception as e:
                    continue
    
    print("📋 Found classes:", sorted(class_counts.keys()))
    for class_id, count in sorted(class_counts.items()):
        print(f"   Class {class_id}: {count} instances")
    
    return class_counts


def create_dataset_yaml():
    """Create dataset YAML file with proper PlantVillage class names"""
    # First diagnose the actual classes in our dataset
    class_counts = diagnose_classes()
    
    # PlantVillage specific class names (complete list)
    PLANTVILLAGE_CLASSES = {
        0: "Apple_Apple_scab",
        1: "Apple_Black_rot",
        2: "Apple_Cedar_apple_rust",
        3: "Apple_healthy",
        4: "Blueberry_healthy",
        5: "Cherry_Powdery_mildew",
        6: "Cherry_healthy",
        7: "Corn_Cercospora_leaf_spot_Gray_leaf_spot",
        8: "Corn_Common_rust",
        9: "Corn_Northern_Leaf_Blight",
        10: "Corn_healthy",
        11: "Grape_Black_rot",
        12: "Grape_Esca",
        13: "Grape_Leaf_blight",
        14: "Grape_healthy",
        15: "Orange_Haunglongbing",
        16: "Peach_Bacterial_spot",
        17: "Peach_healthy",
        18: "Pepper_bell_Bacterial_spot",
        19: "Pepper_bell_healthy",
        20: "Potato_Early_blight",
        21: "Potato_Late_blight",
        22: "Potato_healthy",
        23: "Raspberry_healthy",
        24: "Soybean_healthy",
        25: "Squash_Powdery_mildew",
        26: "Strawberry_Leaf_scorch",
        27: "Strawberry_healthy",
        28: "Tomato_Bacterial_spot",
        29: "Tomato_Early_blight",
        30: "Tomato_Late_blight",
        31: "Tomato_Leaf_Mold",
        32: "Tomato_Septoria_leaf_spot",
        33: "Tomato_Spider_mites_Two-spotted_spider_mite",
        34: "Tomato_Target_Spot",
        35: "Tomato_Tomato_Yellow_Leaf_Curl_Virus",
        36: "Tomato_Tomato_mosaic_virus",
        37: "Tomato_healthy"
    }
    
    if not class_counts:
        print("❌ Error: No classes found in the dataset!")
        # Create default with common plant disease classes
        class_names = ['healthy', 'early_blight', 'late_blight']
        num_classes = 3
    else:
        # Create consecutive class indices from 0 to max class id found
        max_class_id = max(class_counts.keys())
        class_names = []
        
        for class_id in range(max_class_id + 1):
            if class_id in PLANTVILLAGE_CLASSES:
                class_names.append(PLANTVILLAGE_CLASSES[class_id])
            else:
                # Fallback for unexpected class IDs
                class_names.append(f'plant_disease_{class_id}')
        
        num_classes = len(class_names)
    
    # Create YAML content with proper formatting
    yaml_content = {
        'path': str(OUT.resolve()),
        'train': 'images/train',
        'val': 'images/val',
        'test': 'images/test',
        'nc': num_classes,
        'names': class_names,
        
        # Additional metadata
        'description': 'PlantVillage Disease Detection Dataset with Agricultural Augmentations',
        'version': '1.0',
        'author': 'Enhanced with real-world field condition augmentations',
        
        # Agricultural-specific parameters
        'agricultural_augmentations': True,
        'field_conditions': ['sunlight', 'shadow', 'overcast', 'rain', 'wind', 'dew'],
        'min_object_size': '4x4 pixels',
        'augmentation_variants': 3
    }
    
    yaml_file = OUT / 'dataset.yaml'
    with open(yaml_file, 'w') as f:
        yaml.dump(yaml_content, f, default_flow_style=False, sort_keys=False)
    
    print(f"\n✅ Created PlantVillage dataset.yaml with {num_classes} classes")
    print("📊 Final class distribution:")
    for class_id, count in sorted(class_counts.items()):
        class_name = class_names[class_id] if class_id < len(class_names) else f"class_{class_id}"
        print(f"   {class_name}: {count} instances")
    
    print(f"\n🎯 Training with classes: {class_names}")
    return yaml_file


def verify_yaml_structure():
    """Verify the YAML file is properly structured"""
    yaml_file = OUT / 'dataset.yaml'
    if yaml_file.exists():
        with open(yaml_file, 'r') as f:
            config = yaml.safe_load(f)
        
        print(f"\n🔍 Verifying YAML structure:")
        print(f"   Path: {config.get('path', 'Not found')}")
        print(f"   Train: {config.get('train', 'Not found')}")
        print(f"   Val: {config.get('val', 'Not found')}")
        print(f"   Classes: {config.get('nc', 'Not found')}")
        print(f"   Class names: {config.get('names', 'Not found')}")
        
        # Verify paths exist
        train_path = OUT / config['train']
        val_path = OUT / config['val']
        
        print(f"   Train images: {len(list(train_path.rglob('*.jpg')))}")
        print(f"   Val images: {len(list(val_path.rglob('*.jpg')))}")
        
        return True
    return False


if __name__ == '__main__':
    print("🚀 Starting agricultural dataset preparation...")
    print("🌱 Optimized for real-world PlantVillage field conditions")
    
    # Install required packages if missing
    try:
        import albumentations
        print(f"✅ Albumentations version: {albumentations.__version__}")
    except ImportError:
        print("❌ Please install: pip install albumentations")
        exit(1)
    
    # Inspect data
    total_images = inspect_data_structure(ROOT)
    
    if total_images == 0:
        print("❌ No images found in data directory!")
        print("💡 Please ensure your PlantVillage dataset is in the 'data' folder")
        exit(1)
    
    # Find all images and labels
    mapping = find_images_and_labels(ROOT)
    valid_images = sum(1 for v in mapping.values() if v)
    print(f"✅ Valid image-label pairs: {valid_images}/{len(mapping)}")
    
    if valid_images == 0:
        print("❌ No valid image-label pairs found!")
        print("💡 Please check your dataset structure and label files")
        exit(1)
    
    # Prepare dataset with agricultural augmentations
    train_count, val_count, test_count = prepare_agricultural_dataset(
        mapping, 
        augmentations_per_image=2,  # More augmentations for variability
        batch_size=500
    )
    
    # Create YAML file
    yaml_path = create_dataset_yaml()
    
    # Verify the final structure
    verify_yaml_structure()
    
    print(f"\n🎉 Agricultural PlantVillage dataset preparation complete!")
    print(f"📊 Dataset optimized for real-world conditions:")
    print(f"   Training: {train_count} original + augmented field-condition images")
    print(f"   Validation: {val_count} images")
    print(f"   Test: {test_count} images")
    print(f"   Total training images: ~{train_count * 3} (with augmentations)")
    print(f"\n⚙️  Configuration: {yaml_path}")
    