# simple_yolo_dataset_preparation_no_bg.py

import cv2
import numpy as np
import os
from pathlib import Path
from shutil import copyfile
import random

# ----------------- SETTINGS -----------------
PLANTVILLAGE_IMAGES = Path("data/images")    # your PlantVillage images
PLANTVILLAGE_LABELS = Path("data/labels")    # YOLO .txt labels
OUTPUT_IMAGES = Path("dataset3/images")
OUTPUT_LABELS = Path("dataset3/labels")

os.makedirs(OUTPUT_IMAGES, exist_ok=True)
os.makedirs(OUTPUT_LABELS, exist_ok=True)

# ----------------- FUNCTIONS -----------------
def remove_background(img):
    """Remove background using GrabCut"""
    mask = np.zeros(img.shape[:2], np.uint8)
    bgdModel = np.zeros((1,65),np.float64)
    fgdModel = np.zeros((1,65),np.float64)
    h, w = img.shape[:2]
    rect = (5,5,w-5,h-5)
    cv2.grabCut(img, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_RECT)
    mask2 = np.where((mask==2)|(mask==0), 0, 1).astype('uint8')
    img_nobg = img * mask2[:, :, np.newaxis]
    return img_nobg, mask2

def generate_random_background(h, w):
    """Create a random colored or textured background"""
    # Random solid color
    bg_color = np.random.randint(50, 200, size=(3,), dtype=np.uint8)
    bg = np.ones((h, w, 3), dtype=np.uint8) * bg_color  # ensure uint8

    # Add some noise
    noise = np.random.randint(0, 50, (h, w, 3), dtype=np.uint8)
    bg = cv2.add(bg, noise)
    return bg

def paste_on_background(leaf_img, mask):
    h, w = leaf_img.shape[:2]
    bg = generate_random_background(h, w)
    leaf_area = cv2.bitwise_and(leaf_img, leaf_img, mask=mask)
    inv_mask = cv2.bitwise_not(mask)
    bg_area = cv2.bitwise_and(bg, bg, mask=inv_mask)
    combined = cv2.add(leaf_area, bg_area)
    return combined

# ----------------- MAIN -----------------
images_list = list(PLANTVILLAGE_IMAGES.glob("*.jpg"))

for img_path in images_list:
    img = cv2.imread(str(img_path))
    img_nobg, mask = remove_background(img)
    combined = paste_on_background(img_nobg, mask)
    
    # Save new image
    out_img_path = OUTPUT_IMAGES / img_path.name
    cv2.imwrite(str(out_img_path), combined)
    
    # Copy YOLO label
    label_path = PLANTVILLAGE_LABELS / (img_path.stem + ".txt")
    if label_path.exists():
        copyfile(label_path, OUTPUT_LABELS / label_path.name)

print("Dataset preparation complete! All images have synthetic backgrounds.")
