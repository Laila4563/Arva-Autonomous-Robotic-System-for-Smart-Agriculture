# convert_to_segmentation_fixed.py
import os
import numpy as np
from pathlib import Path

def convert_detection_to_segmentation(yolo_format=True):
    """
    Convert all detection annotations to segmentation format.
    If yolo_format=True, bounding boxes are [x_center, y_center, width, height]
    """
    base_path = Path('Merged Datasets')
    
    for split in ['train', 'val', 'test']:
        labels_dir = base_path / split / 'labels'
        
        if not labels_dir.exists():
            print(f"{split}: Labels directory not found: {labels_dir}")
            continue
            
        converted_count = 0
        detection_count = 0
        skipped_files = 0
        
        # Get all label files
        label_files = list(labels_dir.glob('*.txt'))
        print(f"\n{split.upper()}: Processing {len(label_files)} label files...")
        
        for label_file in label_files:
            if not label_file.exists():
                print(f"  Warning: File not found, skipping: {label_file}")
                skipped_files += 1
                continue
            
            try:
                with open(label_file, 'r') as f:
                    lines = f.readlines()
                
                new_lines = []
                changes_made = False
                file_detection_count = 0
                
                for line in lines:
                    parts = line.strip().split()
                    if not parts:
                        continue
                    
                    if len(parts) == 5:  # Detection format
                        file_detection_count += 1
                        detection_count += 1
                        changes_made = True
                        
                        # Convert bounding box to polygon (4-point rectangle)
                        class_id = parts[0]
                        try:
                            x_center, y_center, width, height = map(float, parts[1:5])
                            
                            # Validate values
                            if not (0 <= x_center <= 1 and 0 <= y_center <= 1 and 
                                    0 <= width <= 1 and 0 <= height <= 1):
                                print(f"  Warning: Invalid bbox values in {label_file.name}: {parts[1:5]}")
                                # Keep original line if invalid
                                new_lines.append(line.strip())
                                continue
                            
                            # Convert to corners
                            x_min = x_center - width/2
                            y_min = y_center - height/2
                            x_max = x_center + width/2
                            y_max = y_center + height/2
                            
                            # Create rectangle polygon (4 points)
                            polygon = [
                                x_min, y_min,  # top-left
                                x_max, y_min,  # top-right
                                x_max, y_max,  # bottom-right
                                x_min, y_max   # bottom-left
                            ]
                            
                            # Ensure values are valid (0-1) and not too small
                            polygon = [str(max(0.0, min(1.0, p))) for p in polygon]
                            
                            new_line = f"{class_id} " + " ".join(polygon)
                            new_lines.append(new_line)
                        except ValueError as e:
                            print(f"  Error parsing line in {label_file.name}: {line.strip()} - {e}")
                            new_lines.append(line.strip())
                    else:
                        # Already segmentation, keep as is
                        new_lines.append(line.strip())
                
                if changes_made:
                    # Write back converted file
                    with open(label_file, 'w') as f:
                        f.write("\n".join(new_lines))
                    converted_count += 1
                    
                    if file_detection_count > 0:
                        print(f"  ✓ {label_file.name}: Converted {file_detection_count} boxes")
            
            except Exception as e:
                print(f"  Error processing {label_file}: {e}")
                skipped_files += 1
        
        print(f"{split}:")
        print(f"  Successfully processed: {converted_count} files")
        print(f"  Converted boxes: {detection_count}")
        print(f"  Skipped files: {skipped_files}")

def clean_missing_files():
    """Remove references to missing image/label files"""
    base_path = Path('Merged Datasets')
    
    for split in ['train', 'val', 'test']:
        labels_dir = base_path / split / 'labels'
        images_dir = base_path / split / 'images'
        
        if not labels_dir.exists() or not images_dir.exists():
            continue
        
        print(f"\n{split.upper()}: Cleaning missing files...")
        
        # Check each label file has corresponding image
        for label_file in labels_dir.glob('*.txt'):
            img_found = False
            for ext in ['.jpg', '.jpeg', '.png', '.bmp', '.JPG', '.JPEG', '.PNG']:
                img_file = images_dir / label_file.with_suffix(ext).name
                if img_file.exists():
                    img_found = True
                    break
            
            if not img_found:
                print(f"  Removing orphan label: {label_file.name}")
                label_file.unlink()
        
        # Check each image has corresponding label
        for img_file in images_dir.glob('*'):
            if img_file.suffix.lower() in ['.jpg', '.jpeg', '.png', '.bmp']:
                label_file = labels_dir / img_file.with_suffix('.txt').name
                if not label_file.exists():
                    print(f"  Removing orphan image: {img_file.name}")
                    img_file.unlink()

if __name__ == '__main__':
    print("=" * 60)
    print("DATASET CONVERSION TOOL")
    print("=" * 60)
    
    # Step 1: Clean missing files first
    print("\nSTEP 1: Cleaning missing files...")
    clean_missing_files()
    
    # Step 2: Convert detection to segmentation
    print("\nSTEP 2: Converting detection to segmentation...")
    convert_detection_to_segmentation()
    
    print("\n" + "=" * 60)
    print("CONVERSION COMPLETE!")
    print("=" * 60)