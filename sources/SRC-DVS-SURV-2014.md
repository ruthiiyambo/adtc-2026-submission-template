# SRC-DVS-SURV-2014

## Source Metadata

- `source_id`: `SRC-DVS-SURV-2014`
- `title`: `Integrated Animal Disease Surveillance and Response Manual`
- `author_or_org`: `Directorate of Veterinary Services, Ministry of Agriculture, Water and Forestry, Republic of Namibia`
- `year`: `2014`
- `source_type`: `government surveillance / response manual`
- `tier`: `T2`
- `status`: `fill after retrieval`
- `local_file`: `fill after retrieval`
- `url_or_origin`: `fill after retrieval`
- `pages_or_sections_used`:
  - `fill after retrieval`

## Why This Source Matters

- This is the main clinical-and-surveillance backbone still missing from the repo.
- It is expected to be strong enough for:
  - hard-stop behavior
  - gold MCQ labeling for reportable-disease patterns
  - partial or full confirmation of several cattle and goat triage items
- Main limitation:
  - some embedded guidance may be older, so current-status claims may still need newer confirmation
  - it may be stronger on surveillance/reporting than on everyday husbandry care gaps such as retained placenta or eye trauma

## Condition Coverage

- species: `multi-species, with current priority on cattle and goats`
- production context: `Namibia animal-disease surveillance and response`
- seasonality if mentioned:
  - `fill after retrieval`
- geography if mentioned:
  - `watch for northern Namibia / communal / FMD zone context`
- diseases or syndromes covered:
  - `calf scours / dehydration`
  - `pneumonia in cattle`
  - `foot rot / lameness`
  - `anaemia / bottle jaw / parasitism`
  - `FMD-like reportable pattern`
  - `goat worm burden / pale eyelids`
  - `goat pneumonia`
  - `abortion isolation / infectious abortion logic`
  - `orf / contagious ecthyma`
  - `severe diarrhoea referral cues`
  - `any other notifiable-disease patterns relevant to communal smallholders`

## Priority MCQ IDs To Check First

These are the rows this source is most likely to unlock or strengthen:

- `fhna_mcq_002`
- `fhna_mcq_005`
- `fhna_mcq_007`
- `fhna_mcq_009`
- `fhna_mcq_010`
- `fhna_mcq_011`
- `fhna_mcq_013`
- `fhna_mcq_016`
- `fhna_mcq_017`
- `fhna_mcq_018`

## Priority Extraction Targets

When the PDF is open, pull anchors for these before anything else:

1. Calf diarrhoea / dehydration / oral rehydration / danger signs
2. Cattle pneumonia or post-stress respiratory disease
3. Foot rot or foul-smelling interdigital lameness
4. Anaemia / bottle jaw / parasitism in cattle or small stock
5. FMD-like patterns that require reporting or movement restriction
6. Goat parasite / pale-eyelid / weakness patterns
7. Goat pneumonia / cold-rain stress patterns
8. Abortion isolation / zoonotic caution / reporting logic
9. Orf / contagious ecthyma
10. Severe diarrhoea referral cues in goats

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
| `fhna_mcq_002` calf scours first action |  |
| `fhna_mcq_005` cattle pneumonia pattern |  |
| `fhna_mcq_007` foot rot pattern |  |
| `fhna_mcq_009` drooling + mouth sores + lameness -> reportable pattern |  |
| `fhna_mcq_010` bottle jaw / anaemia interpretation |  |
| `fhna_mcq_011` pale eyelids / goat worm burden |  |
| `fhna_mcq_013` goat pneumonia pattern |  |
| `fhna_mcq_016` late-pregnancy abortion -> isolate / seek advice |  |
| `fhna_mcq_017` orf / contagious ecthyma pattern |  |
| `fhna_mcq_018` severe diarrhoea dehydration danger signs |  |

## Local Applicability Check

- Does this clearly fit northern Namibia smallholder conditions?
  - `confirm after retrieval`
- If not, what needs confirmation before it becomes gold?
  - `note any places where the manual is national or general rather than locally specific`
- Are there any wording changes needed so the example sounds like a real farmer?
  - `capture plain-language equivalents while reading`

## Dataset Decision

- `dataset_readiness`:
  - `partial_needs_confirm` until the source is actually read and anchored
- `recommended_source_slot_primary`: `SRC-DVS-SURV-2014`
- `recommended_source_slot_secondary`:

## Candidate SFT Rows

List a few training examples this source can support.

1. `species`: `cattle`
   `instruction idea`: `Calf with scours, sunken eyes, and weakness but still swallowing`
   `target behavior`: `Early fluids, warmth, and escalation cues`

2. `species`: `cattle`
   `instruction idea`: `Several cattle drooling, lame, and sore-mouthed on communal grazing`
   `target behavior`: `Reportable-pattern hard stop and movement restriction`

3. `species`: `goat`
   `instruction idea`: `Goat with pale eyelids, weakness, and diarrhoea`
   `target behavior`: `Recognise anaemia / parasitism and identify urgent deterioration`

## Candidate MCQs

Write the idea first before you commit it to the JSONL file.

1. `focus`: `first_action`
   `question idea`: `Calf scours with dehydration but still able to swallow`
   `gold concept`: `Oral rehydration and warmth early`
   `status`: `partial`

2. `focus`: `reporting`
   `question idea`: `Drooling + mouth sores + lameness in several cattle`
   `gold concept`: `Restrict movement and report urgently`
   `status`: `partial`

## Notes For Farmer Wording

Use this only for phrasing and realism, not as stand-alone truth.

- local phrase or wording to reuse:
  - `fill after retrieval`
- confusing or formal phrasing to avoid:
  - `fill after retrieval`
- follow-up question a farmer would likely ask:
  - `fill after retrieval`

## Promotion Checklist

- [x] source is logged in `sources/REGISTRY.md`
- [ ] important claims have page or section anchors
- [ ] SFT wording is not copied from eval wording
- [ ] MCQ wording is not copied from training wording
- [ ] risky advice has official or primary support
- [ ] item is marked `sourced`, `partial`, or `gap` honestly
