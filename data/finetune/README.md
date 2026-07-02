# FarmHand NA Fine-Tune Data

This folder is the teach lane. Anything here is intended to change the weights of the final GGUF.

## Put here

- vetted domain knowledge turned into SFT instruction/output pairs
- realistic farmer or extension-officer phrasing
- safety-first responses that cover likely causes, safe first actions, and referral cues

## Do not put here

- exact MCQ wording from `eval/mcq/`
- exact `metadata.json` test prompts
- raw source dumps or raw interview transcripts

## Recommended row fields

- `id`
- `species`
- `instruction`
- `output`
- `source_slot_primary`
- `source_slot_secondary`
- `source_status`
- `review_status`

If your fine-tuning pipeline only consumes `instruction` and `output`, keep the extra audit fields in the seed file and strip them only at export time.

Chat-format seed files are also acceptable at this stage when they preserve
useful system and behavior examples. The imported
[`farmhand_hardstops_seed.jsonl`](farmhand_hardstops_seed.jsonl)
is intentionally kept in `messages` format for that reason.

Starter instruction/output draft:
[`farmhand_na_seed_sft.jsonl`](farmhand_na_seed_sft.jsonl)

Primary-backed legal subset:
[`farmhand_na_legal_seed_sft.jsonl`](farmhand_na_legal_seed_sft.jsonl)
