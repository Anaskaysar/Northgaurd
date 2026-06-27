# Northern Shift Guard — Project Story

## Inspiration

Northern Ontario mines are losing experienced tradespeople to retirement faster than they can replace them. New workers mean more risk — especially at shift start, when fatigue from overnight travel and unfamiliar PPE protocols combine. Yet shift-start safety checks are still done manually: a supervisor glances at a worker, makes a judgment call, and nothing is recorded.

If something goes wrong later — an injury, a liability dispute, an MOL inspection — there is no record of what was checked, what was seen, or what action was recommended. The decision was a black box.

We wanted to change that. Not with another alarm that beeps and gives a confidence score, but with a system that reasons like a safety officer: *what did we see, what does it mean for this specific zone, and what should the supervisor do right now?*

---

## What We Built

**Northern Shift Guard** is a shift-start AI screening tool for Northern Ontario mining operations.

A supervisor selects the mine zone a worker is about to enter — surface yard, open pit, underground ramp, active stope, or processing plant. Each zone has different PPE requirements under **Ontario Regulation 854**. They upload a worker photo. The system:

1. **Detects** PPE compliance (hard hat, hi-vis vest) and visible fatigue cues using **GPT-4o vision**
2. **Checks zone compliance** — not a global rule, but the *specific requirements for that zone* (e.g. surface only requires hi-vis; active stope requires both hard hat and hi-vis under s.81 and s.105)
3. **Reasons** over the evidence using **NVIDIA Nemotron**, producing a plain-language prioritized supervisor action — not just a flag, but *what to actually do and why*, grounded in Ontario mining regulations
4. **Stores** every scan — detected PPE, zone compliance result, Nemotron's full reasoning, and timestamp — in **TiDB Cloud**, building a permanent, traceable audit trail

The result: every shift-start safety decision is explainable, zone-specific, and auditable. No black boxes.

---

## How We Built It

**Stack:**
- **Backend:** FastAPI (Python) — `/api/analyze` accepts an image + zone, runs the full pipeline, persists to TiDB
- **Vision:** GPT-4o with structured JSON output — detects hard hat, hi-vis vest, fatigue indicators, and generates natural-language evidence per region
- **Reasoning:** NVIDIA Nemotron (with GPT-4o-mini fallback) — receives vision evidence + zone context + Ontario Reg 854 safety references, returns a prioritized supervisor action
- **Zone compliance engine:** custom Python service compares detected PPE against zone-specific requirements from a `zones.json` config, producing per-item compliant / non-compliant / not-required status
- **Audit storage:** TiDB Cloud — every scan stores vision JSON, zone compliance result, Nemotron action, provider metadata, and UTC timestamp
- **Frontend:** React + Vite with an industrial dark-theme UI — zone selector, image upload, PPE status cards, zone compliance panel, Nemotron supervisor action, explainable evidence cards, and full audit trail tab

**Pipeline:**
```
Worker photo + zone selection
  → GPT-4o vision → { hard_hat, hi_vis, fatigue_risk, evidence[] }
  → Zone compliance check (detected vs. zone requirements)
  → Nemotron + Ontario Reg 854 context → { priority, supervisor_action, rationale, steps[] }
  → TiDB audit record
  → UI: zone compliance panel + supervisor action + evidence cards
```

---

## Challenges We Faced

**1. Replicate model deprecation**
The original LLaVA-13B model we planned to use via Replicate returned a 422 "version does not exist" error on the day of the hackathon. We pivoted to GPT-4o vision — which turned out to be significantly better quality for structured PPE detection, and supports `response_format: json_object` for reliable parsing.

**2. Making compliance zone-aware, not global**
A naive PPE detector flags everything against the same ruleset. The real insight was that a worker heading to the surface yard only needs hi-vis — flagging them for no hard hat would be wrong. Building the zone compliance layer required defining per-zone requirements (grounded in actual Ontario Reg 854 sections) and making the Nemotron prompt zone-context-aware so its supervisor action reflected the actual zone risk level.

**3. Keeping the reasoning explainable**
It's easy to produce a pass/fail label. It's harder to produce reasoning a supervisor actually trusts. We structured the Nemotron output into four components — priority level, one-sentence action, rationale, and step-by-step recommended actions — so every decision has a transparent chain: *what was seen → what it means for this zone → what to do about it → why*.

**4. Audit trail that survives restarts**
Early in development, `db.py` dropped and recreated the `scans` table on every server restart (fine for local dev, catastrophic for TiDB). We fixed this to `CREATE TABLE IF NOT EXISTS` with `AUTO_INCREMENT` (MySQL/TiDB syntax) so scan history persists across deployments.

---

## What We Learned

- **Zone-aware compliance is the real differentiator.** Generic PPE detectors exist. What mines actually need is a system that knows the difference between a surface check and an underground entry check — and adjusts both the compliance verdict and the supervisor guidance accordingly.
- **GPT-4o vision with structured JSON prompts is production-ready** for safety screening applications. The evidence quality (region + observation + severity) is far beyond what a fine-tuned YOLO classifier alone can provide.
- **Explainability is not a feature — it's a requirement** in regulated industries. Every layer of the system (vision evidence, zone compliance, Nemotron rationale) was designed to answer: *why did the system say that?*

---

## What's Next

- **Webcam / real-time capture** — scan workers as they pass a checkpoint, not just via upload
- **Batch shift scanning** — process an entire crew at once before cage descent
- **TiDB analytics** — shift-over-shift compliance trends, zone risk heatmaps, flagged-worker patterns
- **Expand PPE types** — gloves, safety glasses, respirators, metatarsal boots per zone
- **WSIB / MOL report export** — auto-generate incident documentation from TiDB audit records
