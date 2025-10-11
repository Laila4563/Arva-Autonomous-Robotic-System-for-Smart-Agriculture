import argparse
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

import torch
import torch.nn as nn
import torchreid

def ensure_dir(p: Path):
    if not p.exists():
        p.mkdir(parents=True, exist_ok=True)

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

def load_checkpoint_state(ckpt_path: Path):
    sd = torch.load(str(ckpt_path), map_location="cpu")
    if isinstance(sd, dict) and "state_dict" in sd:
        sd = sd["state_dict"]
    new_sd = {}
    for k, v in sd.items():
        if k.startswith("module."):
            new_sd[k[7:]] = v
        else:
            new_sd[k] = v
    return new_sd

class FeatureWrapper(nn.Module):
    def __init__(self, base):
        super().__init__()
        self.base = base
    def forward(self, x):
        return self.base(x)

def run_pnnx(traced_path: Path, out_dir: Path, imgsX: int, imgsY: int):
    inputshape = f"inputshape=[1,3,{imgsY},{imgsX}]"
    cmd = ["pnnx", str(traced_path), inputshape]
    subprocess.run(cmd, check=True, cwd=str(out_dir))

def find_ncnn_files(out_dir: Path, model_basename: str):
    bin_candidates = list(out_dir.rglob(f"*{model_basename}*.ncnn.bin"))
    param_candidates = list(out_dir.rglob(f"*{model_basename}*.ncnn.param"))
    if not bin_candidates:
        bin_candidates = list(out_dir.rglob("*.ncnn.bin"))
    if not param_candidates:
        param_candidates = list(out_dir.rglob("*.ncnn.param"))
    bin_file = max(bin_candidates, key=lambda p: p.stat().st_mtime) if bin_candidates else None
    param_file = max(param_candidates, key=lambda p: p.stat().st_mtime) if param_candidates else None
    return {"bin": bin_file, "param": param_file}

def main():
    parser = argparse.ArgumentParser(description="Trace TorchReID osnet checkpoint and run pnnx to NCNN.")
    parser.add_argument("--model", required=True, help="Path to checkpoint (.pth) to load (required).")
    parser.add_argument("--imgsX", type=int, default=64, help="Input image width (default: 64)")
    parser.add_argument("--imgsY", type=int, default=128, help="Input image height (default: 128)")
    parser.add_argument("--out", default="./out", help="Output directory (default: ./out)")
    parser.add_argument("--device", default="cpu", help="Device for tracing (cpu or cuda) (default: cpu)")
    args = parser.parse_args()

    ckpt_path = Path(args.model).resolve()
    out_dir = Path(args.out).resolve()
    imgsX = int(args.imgsX)
    imgsY = int(args.imgsY)
    device_str = args.device
    model_basename = ckpt_path.stem  

    print(f"Exporting {model_basename} ({imgsX}, {imgsY}) in {out_dir}")

    try:
        if not ckpt_path.exists():
            raise FileNotFoundError(f"Checkpoint not found: {ckpt_path}")

        ensure_dir(out_dir)

        state_dict = load_checkpoint_state(ckpt_path)

        device = torch.device(device_str)
        model = torchreid.models.osnet.osnet_x0_25(num_classes=751, pretrained=False, feature_dim=512)
        model.load_state_dict(state_dict, strict=False)
        model.eval()
        model.to(device)

        wrapper = FeatureWrapper(model).to(device)
        wrapper.eval()

        traced_name = model_basename + "_traced.pt"
        traced_path = out_dir / traced_name

        example = torch.randn(1, 3, imgsY, imgsX, device=device) 

        with torch.no_grad():
            traced = torch.jit.trace(wrapper, example, strict=False)
            traced.save(str(traced_path))

        time.sleep(0.1)

        run_pnnx(traced_path, out_dir, imgsX, imgsY)

        time.sleep(0.2)

        ncnn = find_ncnn_files(out_dir, model_basename)
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

        keep = {final_bin.resolve(), final_param.resolve(), ckpt_path.resolve()}
        cleanup_out_dir(out_dir, keep_paths=keep)

        print(f"Done: {final_bin.name}, {final_param.name}")
        return 0

    except Exception as e:
        print(f"Failed: {e}")
        return 1

if __name__ == "__main__":
    rc = main()
    sys.exit(rc)