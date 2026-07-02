# FarmHand NA Local Eval Artifacts

This folder contains the first local accuracy artifacts for FarmHand NA. The goal is not to create a final benchmark yet. The goal is to make the first model bake-off meaningful by measuring domain accuracy alongside RAM and throughput.

## Files

- `mcq/farmhand_na_mcq_seed.jsonl`
  - Namibian gold-seed multiple-choice set for local base-model comparison.
- `mcq/farmhand_na_mcq_holdout.jsonl`
  - First never-train holdout set for checking whether improvements transfer beyond the dev set.
- `lm_eval/farmhand_na_mcq.yaml`
  - `lm-evaluation-harness` task config that reads the local JSONL file.
- `../data/finetune/farmhand_na_seed_sft.jsonl`
  - Matching supervised fine-tuning seeds for the same domain and safety style.

## What This Seed Set Is

- English-first v1 cases in more local farmer phrasing from a north-central Namibia smallholder context.
- Focused on cattle and goats, because those are the first two species in scope.
- Designed to probe the exact kinds of knowledge the hidden benchmark is likely to reward: likely causes, safe first actions, urgent referral cues, and a few reporting/containment cases.
- Each item now includes source placeholders so you can tie every question to real veterinary or extension material before trusting it for model selection.

## What This Seed Set Is Not

- Not a final Namibian gold set.
- Not yet source-filled item by item.
- Not yet bilingual.

Every example is marked as draft and should be reviewed against local extension material, veterinary guidance, and your own domain knowledge before you trust it for model selection.

Treat the current MCQ file as a local development set, not training data. Do not train on its exact question text, choices, or rationales. The project-level split between teach / test / support is documented in [../DATA_FLOW.md](../DATA_FLOW.md).

## Question Schema Notes

- `locale`, `production_system`, and `season` make it easier to spot whether the set is drifting away from the real target setting.
- `source_slot_primary` and `source_slot_secondary` are explicit fill-in fields for the Namibian or regional references that justify the question and answer.
- `source_status` should distinguish `sourced`, `partial`, and `gap` items so weak spots stay visible.
- `review_status` should stay loud until each item has been source-filled and checked by you. The current sourcing triage now lives in [../sources/SORTING_MAP.md](../sources/SORTING_MAP.md).

## Recommended Next Curation Pass

1. Replace any remaining formal English with the exact farmer wording you hear in Omusati, Oshana, Ohangwena, or Oshikoto.
2. Fill both source slots on every question before you call the set gold.
3. Tighten any distractors that still feel obviously wrong or culturally unnatural.
4. Keep the holdout file completely out of training and day-to-day prompt iteration so model-picking does not overfit to the same cases.
5. After you choose one written Oshiwambo variety for v1, duplicate a subset in that language for qualitative testing and bonus/demo evidence.

## Benchmark Workflow

The x86 bake-off workflow now lives in [benchmark/README.md](/Users/iiyam112156/farmhand-na/benchmark/README.md:1) and the scripts in [scripts/run_candidate_benchmark.sh](/Users/iiyam112156/farmhand-na/scripts/run_candidate_benchmark.sh:1), [scripts/run_benchmark_pair.sh](/Users/iiyam112156/farmhand-na/scripts/run_benchmark_pair.sh:1), and [scripts/summarize_benchmark.py](/Users/iiyam112156/farmhand-na/scripts/summarize_benchmark.py:1).

## Harness Note

The YAML config uses a local JSON dataset through `dataset_path: json` and `dataset_kwargs.data_files`, following the current `lm-evaluation-harness` custom task guidance for local datasets and multiple-choice tasks.
