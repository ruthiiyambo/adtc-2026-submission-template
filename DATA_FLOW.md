# FarmHand NA Data Flow

This repo already contains the key project fact that should drive data organization: the official ADTC score comes from the submitted GGUF running in `llama.cpp`, not from any extra files that happen to sit in the repository.

## Project facts that decide the structure

- `metadata.json` contributes exactly 2 public prompts, and organizers add 2 hidden prompts.
- `download_model.sh` and the GGUF in `model/` are the scored submission artifact.
- The local MCQ set in `eval/mcq/farmhand_na_mcq_seed.jsonl` is a proxy benchmark used through `eval/lm_eval/farmhand_na_mcq.yaml`.
- Therefore every new item you collect belongs to one of 3 lanes: teach, test, or support.

## Lane 1: Teach the model

Path: `data/finetune/`

Use this lane for information that should end up in the weights of the final model.

Put here:

- vetted facts about likely causes, safe first actions, referral cues, reporting rules, and unsafe actions to avoid
- SFT instruction/output pairs written in realistic farmer or extension-officer wording
- multiple examples for the same topic when you want the model to generalize beyond one phrasing

Rules:

- Do not copy local eval questions, answer options, rationales, or `metadata.json` prompts verbatim into training.
- Farmer interviews can shape wording and priorities, but factual content should still be backed by vetted sources.
- Once source review starts, every SFT example should carry stable source IDs.

## Lane 2: Test the model

Path: `eval/mcq/`

Use this lane for local model selection and overfitting checks.

Put here:

- multiple-choice questions used by `lm-eval`
- a future holdout file such as `eval/mcq/farmhand_na_mcq_holdout.jsonl`
- any local benchmark questions whose only job is measurement

Rules:

- Never train on the exact question text, choices, or rationale from this lane.
- Keep a small holdout set that is never used for tuning or day-to-day prompt iteration.
- Fill `source_slot_primary` and `source_slot_secondary` so each scored item has a paper trail.

Treat the current `farmhand_na_mcq_seed.jsonl` file as a development set until a separate holdout file exists.

## Lane 3: Support the story

Paths: `sources/`, `data/farmer_notes/`, `REPORT.md`

Use this lane for evidence, phrasing, and submission support that are not directly scored by the official loop.

Put here:

- raw PDFs, leaflets, extension notes, and citation extracts
- farmer wording, interview notes, recurring concerns, and seasonal context
- consent notes, source summaries, and report citations

Rules:

- Farmer notes are style and prioritization inputs unless independently backed by a vetted source.
- Cite the same stable source IDs in `REPORT.md`, MCQs, and SFT examples.
- Keep personally identifying details out of saved notes unless you explicitly need them and have consent.

## What to do with each new item

1. Save the vetted source in `sources/` with a stable ID.
2. Write one or more SFT examples in `data/finetune/` if the knowledge should change the model.
3. Write a differently worded MCQ in `eval/mcq/` if the knowledge should be measured locally.
4. Save useful farmer phrasing in `data/farmer_notes/` and reuse it across both lanes without treating it as medical truth by itself.
5. Link the same source ID across the source file, the SFT row, the MCQ row, and `REPORT.md`.

## Recommended immediate shape for this repo

- `data/finetune/farmhand_na_seed_sft.jsonl`
  - teach lane
- `eval/mcq/farmhand_na_mcq_seed.jsonl`
  - local development eval lane
- `eval/mcq/farmhand_na_mcq_holdout.jsonl`
  - never-trained holdout lane
- `eval/lm_eval/farmhand_na_mcq.yaml`
  - local harness config for the dev MCQ set
- `sources/`
  - raw supporting references
- `sources/REGISTRY.md`
  - stable source IDs shared across train, eval, and report
- `sources/SORTING_MAP.md`
  - current source-backed triage for the existing MCQ set
- `data/farmer_notes/`
  - phrasing, concerns, and context from farmer conversations
- `data/finetune/farmhand_hardstops_seed.jsonl`
  - high-priority teach lane for report-not-treat cases

## Non-negotiable wall

The same topic can appear in both training and evaluation, but not in the same surface form. Teach the model the knowledge in `data/finetune/`. Test it with different wording in `eval/mcq/`. That separation is what makes local accuracy believable and what protects you against hidden-prompt overfitting.
