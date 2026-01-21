import os
from pathlib import Path

def convert_bbox_to_polygon(label_dir):
    for label_file in Path(label_dir).glob("*.txt"):
        new_lines = []

        with open(label_file, "r") as f:
            for line in f:
                cls, xc, yc, w, h = map(float, line.strip().split())

                x1 = xc - w / 2
                y1 = yc - h / 2
                x2 = xc + w / 2
                y2 = yc - h / 2
                x3 = xc + w / 2
                y3 = yc + h / 2
                x4 = xc - w / 2
                y4 = yc + h / 2

                # Clip to [0, 1]
                polygon = [max(0, min(1, p)) for p in
                           [x1, y1, x2, y2, x3, y3, x4, y4]]

                new_line = str(int(cls)) + " " + " ".join(map(str, polygon))
                new_lines.append(new_line)

        # Overwrite file with segmentation format
        with open(label_file, "w") as f:
            f.write("\n".join(new_lines))


if __name__ == "__main__":
    convert_bbox_to_polygon("train/labels")
    convert_bbox_to_polygon("val/labels")
    convert_bbox_to_polygon("test/labels")

    print("✅ All labels converted to YOLOv8 segmentation format")
