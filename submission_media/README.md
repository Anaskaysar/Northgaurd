# Devpost Project Media

All images: **1800×1200 (3:2)**, JPG, under 5 MB.

Upload in this order (cover first):

| # | File | Caption for Devpost |
|---|------|---------------------|
| 1 | `00_devpost_cover.jpg` | **Cover** — Northern Shift Guard: zone-aware PPE + fatigue screening for mining |
| 2 | `07_app_dashboard.jpg` | Shift-start dashboard — select mine zone and upload worker photo |
| 3 | `05_demo_scan_results.jpg` | Vision detection + pass/fail cards + Nemotron supervisor action |
| 4 | `02_input_missing_hardhat.jpg` | Demo input: worker missing hard hat |
| 5 | `08_audit_trail.jpg` | SQLite audit trail — every scan stored with zone and evidence |
| 6 | `04_input_fatigue_case.jpg` | Fatigue screening case — visible cues flagged as screening aid |
| 7 | `03_input_compliant_worker.jpg` | Pass case — compliant PPE detected |
| 8 | `01_mining_hero.jpg` | Northern Ontario mining shift-start context |
| 9 | `06_mining_site_context.jpg` | Industrial mine site operations |

## Regenerate

```bash
# App running on localhost:8000
npx playwright screenshot http://127.0.0.1:8000 submission_media/raw/07_app_dashboard.png --viewport-size=1440,900 --full-page --wait-for-timeout=3000
bash scripts/prepare_submission_media.sh
```
