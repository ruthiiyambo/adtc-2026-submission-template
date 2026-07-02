# MCQ Source Unlock Map

This note answers one operational question:

Which missing source is worth retrieving next, and exactly which MCQ IDs does it
unlock or strengthen?

Use this alongside:

- [REGISTRY.md](REGISTRY.md) for source IDs and retrieval status
- [SORTING_MAP.md](SORTING_MAP.md) for the current sourced / partial / gap triage
- [farmhand_na_mcq_seed.jsonl](../eval/mcq/farmhand_na_mcq_seed.jsonl) for the live eval rows

## Fastest Path

1. Retrieve `SRC-DVS-SURV-2014`
2. Retrieve `SRC-AGRIBANK-HP`
3. Retrieve one practical-care / husbandry source for the six true gaps
4. Upgrade the affected MCQs
5. Add matching SFT rows with different wording from eval

## By Missing Source

| Missing source | MCQ IDs it should unlock or strengthen | What changes after retrieval |
|---|---|---|
| `SRC-DVS-SURV-2014` | `fhna_mcq_002`, `fhna_mcq_005`, `fhna_mcq_007`, `fhna_mcq_009`, `fhna_mcq_010`, `fhna_mcq_011`, `fhna_mcq_013`, `fhna_mcq_016`, `fhna_mcq_017`, `fhna_mcq_018` | Main workhorse. Should promote most `partial` rows and reinforce several already-plausible `sourced_needs_vet` rows with primary backing. |
| `SRC-AGRIBANK-HP` | `fhna_mcq_001`, `fhna_mcq_004`, `fhna_mcq_015` | Namibia extension backing for bloat / grain-overload logic and emergency wording. |
| One practical-care source to be identified and registered | `fhna_mcq_003`, `fhna_mcq_006`, `fhna_mcq_008`, `fhna_mcq_012`, `fhna_mcq_014`, `fhna_mcq_020` | Solves the six true gaps: mastitis, retained placenta, newborn calf care, urinary blockage, newborn kid hypothermia, and eye trauma. |
| Clinical skin / ectoparasite source if `SRC-DVS-SURV-2014` is thin on signs | `fhna_mcq_019` | Needed if you want to keep the current clinical mange question as gold rather than only as a legal/notifiable example. |
| `SRC-DVS-POSTERS-2021` | strengthens `fhna_mcq_009` and future public-prompt wording | Useful for farmer-facing report-now wording, but not the highest-priority blocker. |
| `SRC-FAO-ND-Y5162E`, `SRC-FAO-POULTRY-Y5169E`, `SRC-ACIAR-ND-2002`, `SRC-PETRUS-2011` | no direct unlock for the current 20 cattle/goat MCQs | These matter for poultry expansion and future eval rows, not for the present cattle/goat bottleneck. |
| `SRC-WOAH-PPR-2025` | no direct unlock for the current 20 | Important for future PPR hard-stop rows and current-status correctness, not for the present seed MCQs. |

## By MCQ ID

| MCQ ID | Current status | Main missing source | Why it is still blocked |
|---|---|---|---|
| `fhna_mcq_001` | sourced | `SRC-AGRIBANK-HP` | Good candidate, but the primary extension source is still not retrieved into the repo. |
| `fhna_mcq_002` | partial | `SRC-DVS-SURV-2014` | Needs primary backing for calf-scours first action and severity wording. |
| `fhna_mcq_003` | gap | practical-care source | Clinical mastitis diagnosis is not covered by the current legal/reporting material. |
| `fhna_mcq_004` | sourced | `SRC-AGRIBANK-HP` | Strong bloat emergency logic, but still waiting on the direct source file. |
| `fhna_mcq_005` | partial | `SRC-DVS-SURV-2014` | Needs primary support for pneumonia / post-stress respiratory pattern. |
| `fhna_mcq_006` | gap | practical-care source | Retained placenta safe first action needs a husbandry or veterinary-care source. |
| `fhna_mcq_007` | partial | `SRC-DVS-SURV-2014` | Needs direct cattle-facing support for foul-smelling interdigital lameness. |
| `fhna_mcq_008` | gap | practical-care source | Newborn calf warming and colostrum priority needs a care manual. |
| `fhna_mcq_009` | sourced | `SRC-DVS-SURV-2014` as companion to legal sources | Already strong with legal backing, but the surveillance manual should strengthen the disease-pattern half of the item. |
| `fhna_mcq_010` | partial | `SRC-DVS-SURV-2014` | Needs better cattle-specific backing for anaemia / bottle-jaw interpretation. |
| `fhna_mcq_011` | sourced | `SRC-DVS-SURV-2014` | Likely gold once the primary manual is in hand and extracted. |
| `fhna_mcq_012` | gap | practical-care source | Urinary blockage in a wether is not supported by the current source set. |
| `fhna_mcq_013` | sourced | `SRC-DVS-SURV-2014` | Likely gold once primary backing is in hand. |
| `fhna_mcq_014` | gap | practical-care source | Newborn kid warming-before-feeding needs a practical neonatal-care source. |
| `fhna_mcq_015` | sourced | `SRC-AGRIBANK-HP` | Bloat / grain-overload logic is waiting on direct extension backing. |
| `fhna_mcq_016` | sourced | `SRC-DVS-SURV-2014` | Likely gold once the primary abortion / isolate-and-report backing is extracted. |
| `fhna_mcq_017` | sourced | `SRC-DVS-SURV-2014` | Likely gold once the orf guidance is grounded in the retrieved manual. |
| `fhna_mcq_018` | partial | `SRC-DVS-SURV-2014` | Needs primary support for dehydration danger-sign referral wording. |
| `fhna_mcq_019` | partial | clinical skin / mange source, possibly `SRC-DVS-SURV-2014` if it covers signs | `SRC-GN180-2013` backs legal status, but not necessarily the clinical description in the stem. |
| `fhna_mcq_020` | gap | practical-care source | Thorn-eye trauma and cloudy painful eye advice needs a practical-care source. |

## One-Source Wins

- If you retrieve `SRC-DVS-SURV-2014`, you affect the largest number of current rows in one move.
- If you retrieve `SRC-AGRIBANK-HP`, you likely stabilize all current bloat-related cattle and goat items.
- If you retrieve one strong practical-care manual, you can eliminate six current `gap` rows in one move.

## What To Do After Each Retrieval

1. Add or fill the source note in `sources/`.
2. Update the affected MCQ rows in `eval/mcq/farmhand_na_mcq_seed.jsonl`.
3. Add differently worded SFT rows in `data/finetune/`.
4. Only then change an item from `partial` or `gap` to `sourced`.
