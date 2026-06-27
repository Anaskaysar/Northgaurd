#!/bin/bash
# Prepare Devpost gallery images: 3:2 ratio (1800x1200), JPG, under 5MB
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/submission_media"
RAW="$OUT/raw"
mkdir -p "$OUT" "$RAW"

W=1800
H=1200

crop_32() {
  local src="$1"
  local dest="$2"
  # Center-crop to 3:2 then resize to 1800x1200
  cp "$src" "$dest.tmp"
  local pw ph
  pw=$(sips -g pixelWidth "$dest.tmp" | awk '/pixelWidth/{print $2}')
  ph=$(sips -g pixelHeight "$dest.tmp" | awk '/pixelHeight/{print $2}')
  local target_ratio
  target_ratio=$(echo "scale=6; $W / $H" | bc)
  local src_ratio
  src_ratio=$(echo "scale=6; $pw / $ph" | bc)
  if (( $(echo "$src_ratio > $target_ratio" | bc -l) )); then
    local new_w
    new_w=$(echo "scale=0; $ph * $target_ratio / 1" | bc)
    local off_x
    off_x=$(echo "scale=0; ($pw - $new_w) / 2" | bc)
    sips --cropToHeightWidth "$ph" "$new_w" "$dest.tmp" >/dev/null
  else
    local new_h
    new_h=$(echo "scale=0; $pw / $target_ratio / 1" | bc)
    sips --cropToHeightWidth "$new_h" "$pw" "$dest.tmp" >/dev/null
  fi
  sips -s format jpeg -s formatOptions 85 -z "$H" "$W" "$dest.tmp" --out "$dest" >/dev/null
  rm -f "$dest.tmp"
  echo "  -> $dest ($(du -h "$dest" | awk '{print $1}'))"
}

echo "=== Sample / demo images ==="
crop_32 "$ROOT/sample_images/mining-workers-day.jpg" "$OUT/01_mining_hero.jpg"
crop_32 "$ROOT/sample_images/fail_missing_hardhat.jpg" "$OUT/02_input_missing_hardhat.jpg"
crop_32 "$ROOT/sample_images/pass_compliant.jpg" "$OUT/03_input_compliant_worker.jpg"
crop_32 "$ROOT/sample_images/fatigue_tired_operator.jpg" "$OUT/04_input_fatigue_case.jpg"
crop_32 "$ROOT/sample_images/last_scan_result.png" "$OUT/05_demo_scan_results.jpg"
crop_32 "$ROOT/sample_images/images_3.jpg" "$OUT/06_mining_site_context.jpg"

if [ -f "$RAW/01_dashboard.png" ]; then
  echo "=== App screenshots ==="
  crop_32 "$RAW/01_dashboard.png" "$OUT/07_app_dashboard.jpg"
fi
if [ -f "$RAW/07_app_dashboard.png" ]; then
  echo "=== App screenshots ==="
  crop_32 "$RAW/07_app_dashboard.png" "$OUT/07_app_dashboard.jpg"
fi
if [ -f "$RAW/02_audit_trail.png" ]; then
  crop_32 "$RAW/02_audit_trail.png" "$OUT/08_audit_trail.jpg"
fi
if [ -f "$RAW/08_audit_trail.png" ]; then
  crop_32 "$RAW/08_audit_trail.png" "$OUT/08_audit_trail.jpg"
fi
if [ -f "$RAW/09_devpost_cover.png" ]; then
  echo "=== Cover ==="
  crop_32 "$RAW/09_devpost_cover.png" "$OUT/00_devpost_cover.jpg"
fi

echo ""
echo "Done. Upload files from: $OUT/"
ls -lh "$OUT"/*.jpg 2>/dev/null | awk '{print $9, $5}'
