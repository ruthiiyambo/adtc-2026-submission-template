# Sorting Map — Research Packs → Three Lanes

How the two research packs get distributed, and which of the 20 existing MCQs
these sources actually back.

## Lane assignment

- **Support (`sources/`)** — the two research packs go to `sources/research/` marked
  "synthesis, verify against primary." Each primary document gets an ID in
  [REGISTRY.md](REGISTRY.md) and its own file as you retrieve it.
- **Teach (`data/finetune/`)** — the symptom → cause → first-action → refer structure
  for each disease becomes SFT pairs. The two hard-stops below should be
  deliberately over-represented. Starter batch:
  [`data/finetune/farmhand_hardstops_seed.jsonl`](../data/finetune/farmhand_hardstops_seed.jsonl).
- **Test (`eval/mcq/`)** — fill `source_slot_*` fields from the registry and use the
  triage table below to decide what stays, what needs confirmation, and what
  should not be treated as gold yet.

## The two hard-stops

1. Sudden death or tarry blood from orifices → do **not** open the carcass, report now.
2. Notifiable-disease pattern → report to a State Veterinarian, do not self-treat.

## MCQ source-slot triage

| # | Topic | Verdict | Primary source | Note |
|---|-------|---------|----------------|------|
| 1 | Cattle bloat (cause) | Sourced | `SRC-AGRIBANK-HP` | Namibian extension ties bloat to drought-feeding |
| 2 | Calf scours (first action) | Partial | `SRC-DVS-SURV-2014` | Rehydration is general; confirm |
| 3 | Mastitis (cause) | GAP | — | No mastitis entry in packs — source or drop |
| 4 | Bloat → emergency referral | Sourced | `SRC-AGRIBANK-HP` | "Animal down" = emergency, supported |
| 5 | Cattle pneumonia post-transport | Partial | `SRC-DVS-SURV-2014` | Cattle-specific shipping fever is general |
| 6 | Retained placenta (first action) | GAP | — | Not in packs — source or drop |
| 7 | Foot rot (cause) | Partial | `SRC-DVS-SURV-2014` | Small-stock backing is stronger than cattle backing |
| 8 | Newborn calf hypothermia/colostrum | GAP | — | Not in packs — source or drop |
| 9 | FMD pattern → report | Sourced | `SRC-DVS-SURV-2014` + `SRC-AHA-REG-2018` | Strong gold candidate |
| 10 | Bottle jaw / anaemia (cattle) | Partial | `SRC-DVS-SURV-2014` | Cattle applicability is thinner |
| 11 | Goat worms / pale eyelids | Sourced | `SRC-DVS-SURV-2014` | Strong gold candidate |
| 12 | Wether urinary blockage | GAP | — | Not in packs — source or drop |
| 13 | Goat pneumonia | Sourced | `SRC-DVS-SURV-2014` | Ovine/caprine pasteurellosis backed |
| 14 | Newborn kid hypothermia | GAP | — | Not in packs — source or drop |
| 15 | Goat grain overload/bloat | Sourced | `SRC-AGRIBANK-HP` + `SRC-DVS-SURV-2014` | Backed |
| 16 | Doe abortion → isolate/report | Sourced | `SRC-DVS-SURV-2014` | Strong gold candidate |
| 17 | Orf in kids | Sourced | `SRC-DVS-SURV-2014` | Strong gold candidate |
| 18 | Goat diarrhoea → dehydration referral | Partial | `SRC-DVS-SURV-2014` | Danger sign is general; confirm |
| 19 | Mange (cause) | Partial | `SRC-GN180-2013` | Notifiable status backed; clinical detail thin |
| 20 | Goat eye thorn injury | GAP | — | Not in packs — source or drop |

## What this means in practice

- Gold candidates: 1, 4, 9, 11, 13, 15, 16, 17.
- Partials: 2, 5, 7, 10, 18, 19.
- Gaps: 3, 6, 8, 12, 14, 20.

Gap items should stay visibly unsourced until you find a real primary or revise
them toward topics the current source pack actually covers.

For the exact "which missing source unlocks which MCQ IDs" view, use
[MCQ_SOURCE_UNLOCK_MAP.md](MCQ_SOURCE_UNLOCK_MAP.md).
