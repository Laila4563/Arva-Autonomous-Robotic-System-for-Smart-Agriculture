import os
import shutil
import random
from pathlib import Path
from sklearn.model_selection import train_test_split

ROOT = Path('data')  # where Kaggle unzipped
OUT = Path('dataset')
OUT_IMAGES = OUT / 'images'
OUT_LABELS = OUT / 'labels'
RANDOM_STATE = 42

IMAGE_EXTS = {'.jpg', '.jpeg', '.png', '.bmp'}


def inspect_data_structure(root):
    print("Inspecting extracted dataset structure...\n")
    all_imgs = list(root.rglob('*'))
    img_files = [p for p in all_imgs if p.suffix.lower() in IMAGE_EXTS]
    label_files = [p for p in all_imgs if p.suffix.lower() == '.txt']

    print(f"Total images found: {len(img_files)}")
    print(f"Total label files found: {len(label_files)}")

    # Count per folder if subfolders exist
    subfolders = [f for f in root.iterdir() if f.is_dir()]
    if subfolders:
        print("\nSubfolder breakdown:")
        for f in subfolders:
            imgs = list(f.rglob('*'))
            num_imgs = sum(1 for p in imgs if p.suffix.lower() in IMAGE_EXTS)
            num_lbls = sum(1 for p in imgs if p.suffix.lower() == '.txt')
            print(f" - {f.name}: {num_imgs} images, {num_lbls} labels")

    # Print a few examples
    print("\nExample image paths:")
    for p in img_files[:5]:
        print("  ", p)
    print("\nExample label paths:")
    for p in label_files[:5]:
        print("  ", p)
    print("\nInspection complete.\n")


def find_images_and_labels(root):
    imgs = []
    labels = {}
    # find all image files
    for p in root.rglob('*'):
        if p.suffix.lower() in IMAGE_EXTS:
            imgs.append(p)

    # detect if there's a "labels" folder somewhere
    label_root = None
    for sub in root.rglob('labels'):
        if sub.is_dir():
            label_root = sub
            break

    for img in imgs:
        img_name = img.stem + '.txt'
        if label_root:
            txt = label_root / img_name
        else:
            txt = img.with_suffix('.txt')
        if txt.exists():
            labels[str(img)] = str(txt)
        else:
            labels[str(img)] = None
    return labels


def prepare_structure():
    if OUT.exists():
        print('Removing existing dataset/ folder — backup if needed')
        shutil.rmtree(OUT)
    for split in ['train', 'val', 'test']:
        (OUT_IMAGES / split).mkdir(parents=True, exist_ok=True)
        (OUT_LABELS / split).mkdir(parents=True, exist_ok=True)


def copy_split(mapping, frac_val=0.15, frac_test=0.10):
    imgs = list(mapping.items())
    img_paths = [i for i, _ in imgs]
    train_and_val, test = train_test_split(img_paths, test_size=frac_test, random_state=RANDOM_STATE)
    train, val = train_test_split(train_and_val, test_size=frac_val/(1-frac_test), random_state=RANDOM_STATE)

    def copy_items(list_of_images, split):
        for img_path in list_of_images:
            img = Path(img_path)
            src_lbl = Path(mapping[img_path]) if mapping[img_path] else None
            dst_img = OUT_IMAGES / split / img.name
            shutil.copy2(img, dst_img)
            if src_lbl and src_lbl.exists():
                dst_lbl = OUT_LABELS / split / src_lbl.name
                shutil.copy2(src_lbl, dst_lbl)
            else:
                open(OUT_LABELS / split / (img.stem + '.txt'), 'w').close()

    copy_items(train, 'train')
    copy_items(val, 'val')
    copy_items(test, 'test')
    print('Copied splits: train=%d val=%d test=%d' % (len(train), len(val), len(test)))


if __name__ == '__main__':
    inspect_data_structure(ROOT)  

    mapping = find_images_and_labels(ROOT)
    print('Found %d images' % len(mapping))
    with_lbl = sum(1 for v in mapping.values() if v)
    print('%d images have .txt labels; %d do not' % (with_lbl, len(mapping)-with_lbl))

    prepare_structure()
    copy_split(mapping)

    dataset_yaml = OUT / 'dataset.yaml'
    content = {
        'path': str(OUT.resolve()),
        'train': 'images/train',
        'val': 'images/val',
        'test': 'images/test',
        'nc': None,
        'names': None
    }

    possible = list(Path('data').rglob('names*.txt')) + list(Path('data').rglob('classes*.txt'))
    if possible:
        names_file = possible[0]
        names = [l.strip() for l in open(names_file,'r',encoding='utf-8') if l.strip()]
        content['nc'] = len(names)
        content['names'] = names
    else:
        max_id = -1
        for p in (OUT_LABELS).rglob('*.txt'):
            try:
                for line in open(p,'r',encoding='utf-8'):
                    if not line.strip():
                        continue
                    cls = int(line.split()[0])
                    if cls>max_id: max_id=cls
            except Exception:
                pass
        if max_id>=0:
            content['nc'] = max_id+1
            content['names'] = [f'class{i}' for i in range(max_id+1)]
        else:
            content['nc'] = 2
            content['names'] = ['healthy','diseased']

    yaml_text = f"""# Dataset for YOLOv8
path: {content['path']}
train: {content['train']}
val: {content['val']}
test: {content['test']}
nc: {content['nc']}
names: {content['names']}
"""
    open(dataset_yaml,'w',encoding='utf-8').write(yaml_text)
    print('\nWrote dataset.yaml to', dataset_yaml)
    print('--- PLEASE OPEN dataset/dataset.yaml and confirm `names` are correct.')
