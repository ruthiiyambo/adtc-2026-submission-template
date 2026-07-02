# Source Extraction Template

Use this template when you pull a paper, manual, leaflet, regulation, or book
chapter into the FarmHand NA pipeline.

The goal is to turn a source into:

- a clean note in `sources/`
- one or more SFT examples in `data/finetune/`
- one or more MCQs in `eval/mcq/`

Do not turn a source straight into training or eval rows without first writing
down the extract below.

---

## Source Metadata

- `source_id`:
- `title`:
- `author_or_org`:
- `year`:
- `source_type`:
  - example: government manual / regulation / extension leaflet / review paper / textbook chapter
- `tier`:
  - `T1` northern-Namibia-specific
  - `T2` Namibia national or official
  - `T3` Southern Africa regional
  - `T4` general veterinary reference
- `status`:
  - `retrieved`
  - `read`
  - `extracted`
  - `used_in_dataset`
- `local_file`:
- `url_or_origin`:
- `pages_or_sections_used`:

## Why This Source Matters

- What topic or condition does it help with?
- Is it strong enough for:
  - hard-stop behavior
  - gold MCQ labeling
  - only partial confirmation
- What is the main limitation?
  - example: not Namibia-specific / old / general small-stock guidance / legal but not clinical

## Condition Coverage

- species:
- production context:
- seasonality if mentioned:
- geography if mentioned:
- diseases or syndromes covered:

## Extracted Facts

Copy only the facts you actually want to use.

| Field | Notes from source |
|---|---|
| Key signs / pattern |  |
| Most likely cause(s) |  |
| Safe first action(s) |  |
| Referral or emergency cues |  |
| Reporting or legal duty |  |
| Zoonotic concern |  |
| What not to do |  |
| Prevention or follow-up |  |

## Evidence Anchors

For each important claim, leave yourself a page, section, or quotation anchor so
you can re-check it later.

| Claim you may use | Page / section / anchor |
|---|---|
|  |  |
|  |  |
|  |  |

## Local Applicability Check

- Does this clearly fit northern Namibia smallholder conditions?
- If not, what needs confirmation before it becomes gold?
- Are there any wording changes needed so the example sounds like a real farmer?

## Dataset Decision

- `dataset_readiness`:
  - `gold_ready`
  - `partial_needs_confirm`
  - `support_only`
- `recommended_source_slot_primary`:
- `recommended_source_slot_secondary`:

## Candidate SFT Rows

List a few training examples this source can support.

1. `species`:
   `instruction idea`:
   `target behavior`:

2. `species`:
   `instruction idea`:
   `target behavior`:

3. `species`:
   `instruction idea`:
   `target behavior`:

## Candidate MCQs

Write the idea first before you commit it to the JSONL file.

1. `focus`:
   `question idea`:
   `gold concept`:
   `status`: `sourced` / `partial` / `gap`

2. `focus`:
   `question idea`:
   `gold concept`:
   `status`: `sourced` / `partial` / `gap`

## Notes For Farmer Wording

Use this only for phrasing and realism, not as stand-alone truth.

- local phrase or wording to reuse:
- confusing or formal phrasing to avoid:
- follow-up question a farmer would likely ask:

## Promotion Checklist

- [ ] source is logged in `sources/REGISTRY.md`
- [ ] important claims have page or section anchors
- [ ] SFT wording is not copied from eval wording
- [ ] MCQ wording is not copied from training wording
- [ ] risky advice has official or primary support
- [ ] item is marked `sourced`, `partial`, or `gap` honestly
