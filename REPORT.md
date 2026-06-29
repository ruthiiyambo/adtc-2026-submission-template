# Technical Report — FarmHand NA

**Team ID:** TODO_TEAM_ID  
**Domain:** agriculture  
**Model:** TBD final 2B-4B GGUF Q4_K_M candidate

---

## Problem

FarmHand NA is an offline livestock-health triage assistant for smallholder farmers and agricultural extension officers in northern Namibia. The intended user describes symptoms in plain language and receives likely causes, safe first actions, and clear referral cues for severe or time-sensitive cases.

This use case matters because veterinary access is sparse, transport is expensive, and connectivity is inconsistent. A farmer often has to decide what to do before a veterinarian or extension officer can be reached. Running fully offline on a low-spec laptop makes the system usable in the field, in schools, in clinics, and during outreach visits without depending on mobile data or cloud APIs.

The project also targets a real African language access gap. The demo experience is designed around English plus one verified written Oshiwambo variety for v1, while the scored submission focuses first on maximizing the benchmarked quality of the underlying on-device model.

---

## Design Decisions

### Score-first reality

The official ADTC profiler currently measures throughput with `llama-bench` using `-p 512 -n 128`. The public rules and placeholder scorer reference `TPS_REFERENCE = 15.0`, which makes `~15 tokens/sec` a strong working target, but the final normalization logic is still described as provisional and the server-side scoring formula is not fully exposed. Memory efficiency is normalized against a 7.0 GB peak RSS reference inside the 8 GB evaluation envelope. This means the submission should optimize in this order:

1. Maximize hidden-set accuracy.
2. Stay safely below the memory cliff on x86 Ubuntu.
3. Reach roughly 15 tokens/sec on the participant-style machine, then only keep chasing speed if it also improves thermals or memory.

Because the scored loop is the bare GGUF in `llama.cpp`, the app, bilingual UI, and any retrieval system do not improve benchmark accuracy. Knowledge has to live in the weights.

### Base-model strategy

The current v1 strategy is to benchmark strong small open models in the 2B-4B range before committing to any fine-tune:

| Candidate | Why it is on the shortlist | Main risk |
|---|---|---|
| `Qwen3-4B` | Strong multilingual base, public Apache-2.0 weights, supported in `llama.cpp`, and large enough to carry more factual/domain knowledge than 1B-2B models. | May be slower than smaller options on a 4 vCPU laptop; must verify x86 thermals and RSS. |
| `Phi-4-mini-instruct` | Built for memory/compute-constrained settings and competitive at 3.8B. | Strong general reasoning does not guarantee best agriculture knowledge. |
| `Phi-4-mini-reasoning` | Excellent compact reasoning profile and easy public access. | Officially optimized for math reasoning and explicitly weaker on stored factual knowledge, which may hurt the hidden agriculture multiple-choice score. |
| `Gemma 3/4 small variants` | Strong small-model family with multilingual coverage. | Gated or license-friction downloads can break the no-credentials submission flow unless the final GGUF is hosted publicly and ungated. |

### Fine-tuning strategy

Fine-tuning is optional for v1 and only worth the added complexity if the best no-tune baseline is clearly knowledge-limited on livestock-health evaluation. The planned order is:

1. Benchmark untuned GGUF baselines on the target x86 Ubuntu profile.
2. Run a small local agriculture evaluation set that mirrors hidden-task behavior as multiple-choice or short factual selection.
3. Only then decide whether to do LoRA fine-tuning or continued pretraining on regional livestock-health material.

If tuning is needed, the highest-value data is not generic chatbot dialogue. It is domain knowledge that teaches the model animal-disease patterns, safe first actions, contraindications, and referral cues in a form that transfers to multiple-choice evaluation. Bilingual adaptation matters for the demo and the African use-case bonus, but it should not come at the expense of the hidden English-domain score unless benchmarking proves otherwise.

### Quantization choice

`GGUF Q4_K_M` is fixed by the competition rules and is also a reasonable balance for this track. It is usually small enough to fit a 2B-4B model well inside the 8 GB limit while preserving more quality than more aggressive low-bit variants. Larger quantizations are out of scope for the final submission, so effort should go into base-model choice and data quality rather than quantization exploration.

---

## Constraints

- Target environment: Ubuntu laptop profile with 4 vCPU, 8 GB RAM, and integrated graphics only.
- Runtime: `llama.cpp` only. No cloud inference, no internet, and no external APIs during evaluation.
- Submission artifact: GGUF weights only, fetched by `download_model.sh` from a public URL.
- Profiler reality: self-reported numbers are compared against audit numbers, so profiling on Apple Silicon is not trustworthy enough for the final claim.
- Thermal penalty: performance that looks good in a short run but triggers throttling can lose points overall.
- Domain safety: livestock-health guidance must stay conservative, especially around poisoning, severe dehydration, birthing emergencies, and referral thresholds.

---

## Benchmarks

### Current status

Benchmarking is not complete yet. The project is still in model-selection stage, and the final numbers must be collected on an x86 Ubuntu environment that matches the ADTC participant profile as closely as possible.

### Benchmark worksheet for v1

| Metric | Value |
|---|---|
| Machine | TODO x86 Ubuntu 8 GB participant-style machine |
| Candidate 1 | TODO |
| Candidate 1 peak RSS | TODO |
| Candidate 1 generation speed | TODO |
| Candidate 1 thermal result | TODO |
| Candidate 2 | TODO |
| Candidate 2 peak RSS | TODO |
| Candidate 2 generation speed | TODO |
| Candidate 2 thermal result | TODO |
| Final selected model | TODO |

### What will count as a good v1

- Peak RSS comfortably below 7.0 GB on the participant-style machine.
- Generation speed near or above 15 tokens/sec, since extra speed beyond that has diminishing leaderboard value.
- No thermal penalty during repeated profiler runs.
- Best hidden-set proxy accuracy among the 2B-4B shortlist, even if that model is not the very fastest.

These are self-reported development benchmarks. Official scores are measured by the ADTC profiler on the standard evaluation machine.
