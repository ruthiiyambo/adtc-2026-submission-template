# SRC-AGRIBANK-HP

## Source Metadata

- `source_id`: `SRC-AGRIBANK-HP`
- `title`: `Basic Livestock Health Plan`
- `author_or_org`: `Agribank Namibia / Ngaruka (confirm after retrieval)`
- `year`: `fill after retrieval`
- `source_type`: `government-bank extension leaflet / livestock health guide`
- `tier`: `T2`
- `status`: `fill after retrieval`
- `local_file`: `fill after retrieval`
- `url_or_origin`: `fill after retrieval`
- `pages_or_sections_used`:
  - `fill after retrieval`

## Why This Source Matters

- This is the most likely Namibia-specific extension source for current bloat and grain-overload items.
- It is expected to be strong enough for:
  - gold MCQ labeling on bloat / rumen-gas build-up patterns
  - emergency referral wording for severe bloat
  - practical prevention and first-action guidance in farmer-facing language
- Main limitation:
  - it is likely narrower than the DVS surveillance manual
  - it may help mainly with bloat, feeding transitions, and calendar-style husbandry advice rather than broader clinical triage

## Condition Coverage

- species: `cattle and possibly goats / small stock`
- production context: `Namibia livestock extension / smallholder-friendly husbandry guidance`
- seasonality if mentioned:
  - `watch for drought, first rains, lush grazing, and feed-transition context`
- geography if mentioned:
  - `confirm after retrieval`
- diseases or syndromes covered:
  - `cattle bloat after lush grazing`
  - `bloat emergency cues`
  - `grain overload / concentrate access`
  - `prevention through gradual feed introduction`
  - `vaccination calendar or routine preventive guidance, if present`

## Priority MCQ IDs To Check First

These are the rows this source is most likely to unlock or strengthen:

- `fhna_mcq_001`
- `fhna_mcq_004`
- `fhna_mcq_015`

## Priority Extraction Targets

When the source is open, pull anchors for these before anything else:

1. Bloat pattern after fresh green grazing or sudden feed change in cattle
2. Emergency cues for severe bloat such as breathing distress, inability to settle, or collapse risk
3. Grain overload / concentrate access causing rumen upset or bloat in goats or other stock
4. Safe first-action wording for bloat that is suitable for farmer-facing use
5. Prevention advice such as gradual introduction to lush feed or concentrates
6. Any vaccination-calendar or seasonal husbandry material that may be useful later

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
| `fhna_mcq_001` rapid left-sided swelling after lush grazing -> bloat |  |
| `fhna_mcq_004` open-mouth breathing / collapse risk -> emergency |  |
| `fhna_mcq_015` feed or maize-meal access -> grain overload / rumen upset / bloat |  |
| prevention advice for gradual feed transition |  |
| any Namibia vaccination-calendar material worth reusing later |  |

## Local Applicability Check

- Does this clearly fit northern Namibia smallholder conditions?
  - `confirm after retrieval`
- If not, what needs confirmation before it becomes gold?
  - `note where the guide is general extension advice versus a clearly local recommendation`
- Are there any wording changes needed so the example sounds like a real farmer?
  - `capture simple phrases for belly swelling, fresh green grazing, feed bags, and emergency language`

## Dataset Decision

- `dataset_readiness`:
  - `partial_needs_confirm` until the source is actually read and anchored
- `recommended_source_slot_primary`: `SRC-AGRIBANK-HP`
- `recommended_source_slot_secondary`:

## Candidate SFT Rows

List a few training examples this source can support.

1. `species`: `cattle`
   `instruction idea`: `Cow with fast left-sided swelling after first green flush grazing`
   `target behavior`: `Recognise likely bloat, give safe first actions, and escalate fast if breathing is affected`

2. `species`: `goat`
   `instruction idea`: `Goat broke into maize meal or poultry feed and soon became swollen and uncomfortable`
   `target behavior`: `Recognise grain overload / rumen upset / bloat and identify emergency cues`

3. `species`: `cattle`
   `instruction idea`: `How do I reduce bloat risk when animals move onto lush feed after dry conditions?`
   `target behavior`: `Use gradual feed transition and other prevention advice from the extension source`

## Candidate MCQs

Write the idea first before you commit it to the JSONL file.

1. `focus`: `likely_cause`
   `question idea`: `Cow on fresh green grazing develops rapid left-flank swelling and belly discomfort`
   `gold concept`: `Bloat or severe rumen gas build-up`
   `status`: `partial`

2. `focus`: `referral_cue`
   `question idea`: `Same bloat case now has open-mouth breathing and looks ready to fall`
   `gold concept`: `This is an emergency needing urgent help now`
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
