# Technical Report — FarmHand NA

**Team ID:** farmhand-na  
**Domain:** agriculture  
**Model:** `Phi-4-mini-instruct-Q4_K_M` (current submission candidate)

---

## Problem

FarmHand NA is an offline livestock-health triage assistant for smallholder farmers and agricultural extension officers in northern Namibia. The intended user describes symptoms in plain language and receives likely causes, safe first actions, and clear referral cues for severe or time-sensitive cases.

This use case matters because veterinary access is sparse, transport is expensive, and connectivity is inconsistent. A farmer often has to decide what to do before a veterinarian or extension officer can be reached. Running fully offline on a low-spec laptop makes the system usable in the field, in schools, in clinics, and during outreach visits without depending on mobile data or cloud APIs.

The project also targets a real African language access gap. The demo experience is designed around English plus verified written Oshindonga for v1, while the scored submission focuses first on maximizing the benchmarked quality of the underlying on-device model.

---

## Design Decisions

### Score-first reality

The public ADTC materials are specific enough now to shape development priorities. The official profiler uses `llama-bench`, exposes a participant self-check mode, an audit mode, a JSON comparison step, and a leaderboard formula that weights accuracy, throughput, and memory while applying a thermal penalty. The published scorer normalizes throughput against `TPS_REFERENCE = 15.0`, normalizes memory efficiency against a `RAM_LIMIT_GB = 7.0` reference inside the 8 GB laptop envelope, and deducts 10 points if CPU throttling occurs or core temperature exceeds 85 C. That means the submission should optimize in this order:

1. Maximize hidden-set accuracy.
2. Stay safely below the memory cliff on x86 Ubuntu.
3. Reach roughly 15 tokens/sec on the participant-style machine, then only keep chasing speed if it also improves thermals or memory.

The official comparison tolerances also matter for validation discipline: peak and steady-state RSS are allowed roughly +/-15% before being flagged, while generation throughput and first-token latency are allowed roughly +/-25% before being flagged. Because the scored loop is the bare GGUF in `llama.cpp`, the app, bilingual UI, and any retrieval system do not improve benchmark accuracy. Knowledge has to live in the weights.

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

If tuning is needed, the highest-value data is not generic chatbot dialogue. It is domain knowledge that teaches the model animal-disease patterns, safe first actions, contraindications, and referral cues in a form that transfers to multiple-choice evaluation. Bilingual adaptation matters for the demo and the African use-case bonus, but it should not come at the expense of the hidden English-domain score unless benchmarking proves otherwise. The newly announced UDUTech credits are useful here for one-off fine-tuning or ablation runs, but they do not change the fact that the final benchmark must still run on the standard ADTC laptop profile.

### Quantization choice

`GGUF Q4_K_M` is fixed by the competition rules and is also a reasonable balance for this track. It is usually small enough to fit a 2B-4B model well inside the 8 GB limit while preserving more quality than more aggressive low-bit variants. Larger quantizations are out of scope for the final submission, so effort should go into base-model choice and data quality rather than quantization exploration.

---

## Constraints

- Target environment: Ubuntu laptop profile with 4 vCPU, 8 GB RAM, and integrated graphics only.
- Runtime: `llama.cpp` only. No cloud inference, no internet, and no external APIs during evaluation.
- Submission artifact: GGUF weights only, fetched by `download_model.sh` from a public URL.
- Profiler reality: self-reported participant runs are compared against audit runs, so profiling on Apple Silicon is not trustworthy enough for the final claim.
- Thermal penalty: performance that looks good in a short run but triggers throttling or pushes core temperature above 85 C can lose points overall.
- Domain safety: livestock-health guidance must stay conservative, especially around poisoning, severe dehydration, birthing emergencies, and referral thresholds.

---

## Benchmarks

### Current status

The repo has now completed both of the most important early validation steps on a Google Cloud Ubuntu 22.04.5 `x86_64` VM with `4 vCPU / 8 GB RAM`:

1. A participant-style `adtc-profiler` smoke test for `Qwen3-4B-Q4_K_M` on July 8, 2026, proving the pipeline, runtime, and basic memory fit on the target class of machine.
2. A side-by-side native `llama.cpp` benchmark for `Qwen3-4B` versus `Phi-4-mini-instruct` on July 9, 2026, measuring generation throughput, peak RSS, and local FarmHand NA multiple-choice accuracy.
3. A participant-style `adtc-profiler` rerun for `Phi-4-mini-instruct-Q4_K_M` on July 12, 2026, confirming the selected submission candidate on the target class of machine after the repo was frozen around the chosen model.

Observed July 8 participant-style smoke result:

- Machine: Google Cloud Ubuntu 22.04.5 LTS, `x86_64`, `4 vCPU / 8 GB RAM`
- Model: `Qwen3-4B-Q4_K_M`
- Generation throughput: `8.46 tokens/sec`
- Peak RSS: `4380.61 MB`
- Thermal status: unavailable on this cloud VM because hardware sensors were not exposed to the guest

Observed July 9 side-by-side benchmark result:

- `Qwen3-4B-Q4_K_M`
  - `throughput_tps = 11.3916`
  - `throughput_peak_rss_mb = 3745.64`
  - `mcq_eval_peak_rss_mb = 7121.34`
  - `mcq_accuracy = 0.75`
- `Phi-4-mini-instruct-Q4_K_M`
  - `throughput_tps = 12.068`
  - `throughput_peak_rss_mb = 3887.45`
  - `mcq_eval_peak_rss_mb = 6716.28`
  - `mcq_accuracy = 0.85`

Observed July 12 participant-style Phi rerun:

- Machine: Google Cloud Ubuntu 22.04.5 LTS, `x86_64`, `4 vCPU / 8 GB RAM`
- Model: `Phi-4-mini-instruct-Q4_K_M`
- Generation throughput: `6.51 tokens/sec`
- Peak RSS: `3910.79 MB`
- Thermal status: no throttling observed; core temperature not exposed by the cloud VM guest

Interpretation: `Phi-4-mini-instruct-Q4_K_M` is the selected submission candidate. It was modestly faster than Qwen in the side-by-side benchmark, achieved higher local MCQ accuracy, and stayed below the rough `7.0 GB` memory reference during the native MCQ evaluation pass. The later participant-style rerun confirmed stable memory fit on the Ubuntu target profile, even though generation throughput on that run was lower than the controlled pair-benchmark measurement. Qwen remained viable, but its MCQ leg was slightly above the memory reference while also scoring lower on the local seed set.

The validation sequence for the final artifact is:

1. Run the repo's pair benchmark to choose the best candidate on local MCQ accuracy, RAM, and generation speed.
2. Run `adtc-profiler run --mode participant --skip-accuracy` on the frozen submission repo.
3. Preserve the resulting `submission.json` so it can later be compared against the organizer-side audit JSON with `adtc-profiler compare`.

Steps 1 and 2 are now complete for the current Phi submission candidate.

On July 26, 2026, a local Apple M4 dry-run of `adtc-profiler run --mode participant --skip-accuracy` was executed against the frozen Phi repo to validate the end-to-end pipeline and confirm that the filled-in `metadata.json` now flows correctly into `submission.json`. The regenerated artifact carries the correct `team_id`, submitter details, and `Phi-4-mini-instruct-Q4_K_M` model info (`architecture = phi3`, `params_match = true`) at commit `599c221d`. This dry-run recorded `30.86 tokens/sec` and `2546.51 MB` peak RSS with no observed throttling. These Apple Silicon numbers are for pipeline validation only and are not the scored figures — the authoritative `submission.json` must still be produced by `scripts/run_x86_vm_smoke.sh` on the x86 Ubuntu target profile.

### Benchmark worksheet for v1

| Metric | Value |
|---|---|
| Machine | Google Cloud Ubuntu 22.04.5 LTS `x86_64`, `4 vCPU / 8 GB RAM` |
| Candidate 1 | `Qwen3-4B-Q4_K_M` |
| Candidate 1 participant smoke peak RSS | `4380.61 MB` |
| Candidate 1 participant smoke generation speed | `8.46 tokens/sec` |
| Candidate 1 pair benchmark throughput RSS | `3745.64 MB` |
| Candidate 1 pair benchmark throughput speed | `11.3916 tokens/sec` |
| Candidate 1 pair benchmark MCQ RSS | `7121.34 MB` |
| Candidate 1 pair benchmark MCQ accuracy | `0.75 acc_norm` |
| Candidate 2 | `Phi-4-mini-instruct-Q4_K_M` |
| Candidate 2 pair benchmark throughput RSS | `3887.45 MB` |
| Candidate 2 pair benchmark throughput speed | `12.068 tokens/sec` |
| Candidate 2 pair benchmark MCQ RSS | `6716.28 MB` |
| Candidate 2 pair benchmark MCQ accuracy | `0.85 acc_norm` |
| Candidate 2 participant smoke peak RSS | `3910.79 MB` |
| Candidate 2 participant smoke generation speed | `6.51 tokens/sec` |
| Candidate thermal result | `N/A on GCP VM; sensors not exposed` |
| Final selected model | `Phi-4-mini-instruct-Q4_K_M` confirmed in participant-style profiler reruns |

### What will count as a good v1

- Peak RSS comfortably below 7.0 GB on the participant-style machine.
- Generation speed near or above 15 tokens/sec, since extra speed beyond that has diminishing leaderboard value.
- No thermal penalty during repeated profiler runs and no excursions above the published 85 C threshold.
- Best hidden-set proxy accuracy among the 2B-4B shortlist, even if that model is not the very fastest.

These are self-reported development benchmarks. Official scores are measured by the ADTC profiler on the standard evaluation machine.
