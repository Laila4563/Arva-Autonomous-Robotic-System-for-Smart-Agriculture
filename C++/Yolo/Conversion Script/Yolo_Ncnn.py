import argparse
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path
from ultralytics import YOLO

def find_torchscript_file(search_dirs, model_basename):
    candidates = []
    for base in search_dirs:
        for p in Path(base).rglob("*"):
            if not p.is_file():
                continue
            name = p.name.lower()
            if ("torchscript" in name and (name.endswith(".torchscript") or name.endswith(".pt"))) \
               or name.endswith(".torchscript") or name.endswith(".pt"):
                candidates.append(p)
            elif model_basename.lower() in name and (name.endswith(".torchscript") or name.endswith(".pt")):
                candidates.append(p)
    if not candidates:
        return None
    return max(candidates, key=lambda p: p.stat().st_mtime)

def run_pnnx_on_file(torchscript_path: Path, out_dir: Path):
    cmd = ["pnnx", str(torchscript_path)]
    subprocess.run(cmd, check=True, cwd=str(out_dir))

def gather_ncnn_files(out_dir: Path, model_basename: str):
    bin_candidates = list(out_dir.rglob(f"*{model_basename}*.ncnn.bin"))
    param_candidates = list(out_dir.rglob(f"*{model_basename}*.ncnn.param"))

    if not bin_candidates:
        bin_candidates = list(out_dir.rglob("*.ncnn.bin"))
    if not param_candidates:
        param_candidates = list(out_dir.rglob("*.ncnn.param"))

    bin_file = max(bin_candidates, key=lambda p: p.stat().st_mtime) if bin_candidates else None
    param_file = max(param_candidates, key=lambda p: p.stat().st_mtime) if param_candidates else None

    return {"bin": bin_file, "param": param_file}

def cleanup_out_dir(out_dir: Path, keep_paths):
    keep_norm = {p.resolve() for p in keep_paths}
    for entry in list(out_dir.iterdir()):
        try:
            entry_res = entry.resolve()
        except Exception:
            entry_res = entry
        if entry_res in keep_norm:
            continue
        if entry.is_dir():
            shutil.rmtree(entry, ignore_errors=True)
        else:
            try:
                entry.unlink()
            except Exception:
                pass

def ensure_dir(p: Path):
    if not p.exists():
        p.mkdir(parents=True, exist_ok=True)

def export_model_force_location(model_path: Path, imgsX: int, imgsY: int, out_dir: Path, model_basename: str):
    if not model_path.exists():
        raise FileNotFoundError(f"Model file not found: {model_path}")
    ensure_dir(out_dir)

    imgsz = (imgsx := imgsX, imgsy := imgsY)
    model = YOLO(str(model_path))
    model.export(format="torchscript", imgsz=imgsz, project=str(out_dir), name=model_basename)

def main():
    parser = argparse.ArgumentParser(description="Export YOLO -> TorchScript -> pnnx -> keep ncnn files (renamed).")
    parser.add_argument("--model", required=True, help="Path to the YOLO model file (.pt).")
    parser.add_argument("--imgsX", type=int, default=640, help="Input image width (default: 640)")
    parser.add_argument("--imgsY", type=int, default=640, help="Input image height (default: 640)")
    parser.add_argument("--out", default="./out", help="Output directory (default: ./out)")
    args = parser.parse_args()

    model_path = Path(args.model).resolve()
    out_dir = Path(args.out).resolve()
    imgsX = int(args.imgsX)
    imgsY = int(args.imgsY)
    model_basename = model_path.stem 

    print(f"Exporting {model_basename} ({imgsX}, {imgsY}) in {out_dir}")

    try:
        export_model_force_location(model_path, imgsX, imgsY, out_dir, model_basename)

        time.sleep(0.3)

        search_dirs = [out_dir, model_path.parent, Path.cwd()]
        ts_file = find_torchscript_file(search_dirs, model_basename)
        if not ts_file:
            raise RuntimeError("Could not find exported TorchScript file after export")

        target_ts = out_dir / (model_basename + ".torchscript")
        if ts_file.resolve() != target_ts.resolve():
            ensure_dir(out_dir)
            shutil.move(str(ts_file), str(target_ts))
            ts_file = target_ts

        time.sleep(0.1)

        run_pnnx_on_file(ts_file, out_dir)

        time.sleep(0.2)

        ncnn = gather_ncnn_files(out_dir, model_basename)
        if not ncnn["bin"] or not ncnn["param"]:
            all_bin = list(out_dir.rglob("*.ncnn.bin"))
            all_param = list(out_dir.rglob("*.ncnn.param"))
            if all_bin and all_param:
                ncnn["bin"] = max(all_bin, key=lambda p: p.stat().st_mtime)
                ncnn["param"] = max(all_param, key=lambda p: p.stat().st_mtime)

        if not ncnn["bin"] or not ncnn["param"]:
            raise RuntimeError("pnnx did not produce required .ncnn.bin and/or .ncnn.param files in out dir")

        target_bin_ncnn = out_dir / (model_basename + ".ncnn.bin")
        target_param_ncnn = out_dir / (model_basename + ".ncnn.param")
        if ncnn["bin"].resolve() != target_bin_ncnn.resolve():
            shutil.move(str(ncnn["bin"]), str(target_bin_ncnn))
        if ncnn["param"].resolve() != target_param_ncnn.resolve():
            shutil.move(str(ncnn["param"]), str(target_param_ncnn))

        final_bin = out_dir / (model_basename + ".bin")
        final_param = out_dir / (model_basename + ".param")
        os.replace(str(target_bin_ncnn), str(final_bin))
        os.replace(str(target_param_ncnn), str(final_param))

        keep = {final_bin.resolve(), final_param.resolve(), model_path.resolve()}
        cleanup_out_dir(out_dir, keep_paths=keep)

        print(f"Done: {final_bin.name}, {final_param.name}")
        return 0

    except Exception as e:
        print(f"Failed: {e}")
        return 1

if __name__ == "__main__":
    rc = main()
    sys.exit(rc)
