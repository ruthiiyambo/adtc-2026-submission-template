# FarmHand NA x86 Benchmark Workflow

This workflow is for the real model bake-off on a participant-style Ubuntu machine. It compares candidate GGUFs on the three things that matter now:

1. `llama-bench` generation throughput.
2. Peak RSS during the throughput run.
3. Local domain accuracy on the FarmHand NA MCQ seed set.

It is intentionally CPU-only for the comparison run so the numbers are stable and easy to compare across x86 machines. If you later want to test integrated-GPU offload, do that as a separate experiment, not as the baseline comparison.

The throughput leg is ADTC-aligned, not byte-for-byte identical to the public profiler implementation. The public profiler source calls `llama-bench` with the `-p 512 -n 128` test shape and optional thread count. This repo's comparison script keeps that shape but also pins the run to CPU-only and repeats it in a controlled way so your candidate bake-off is stable on the Ubuntu box.

## What The Scripts Do

- [scripts/run_candidate_benchmark.sh](/Users/iiyam112156/farmhand-na/scripts/run_candidate_benchmark.sh:1)
  - Runs `llama-bench` on one model with the ADTC-aligned `-p 512 -n 128` shape.
  - Measures peak RSS for that run with GNU `/usr/bin/time -v`.
  - Starts `llama-server` locally on CPU only.
  - Runs `lm-eval` against the local server with the FarmHand NA MCQ task.
  - Saves raw outputs plus a normalized `summary.json`.
- [scripts/run_benchmark_pair.sh](/Users/iiyam112156/farmhand-na/scripts/run_benchmark_pair.sh:1)
  - Runs the single-model script twice using one env file for `Qwen3-4B` and `Phi-4-mini`.
- [scripts/summarize_benchmark.py](/Users/iiyam112156/farmhand-na/scripts/summarize_benchmark.py:1)
  - Parses raw SQL, JSON, and GNU time outputs into one compact summary per model.

## Prerequisites On The Ubuntu Box

Install system packages:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake python3.11 python3.11-venv curl git
```

Build `llama.cpp` tools:

```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cmake -B build
cmake --build build --config Release -t llama-bench -t llama-server
```

Create a Python environment and install the two benchmark-side Python tools:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git"
pip install "git+https://github.com/EleutherAI/lm-evaluation-harness.git"
```

## Candidate Model Setup

Put your GGUF files somewhere local on the Ubuntu box, for example:

```text
/models/qwen3-4b/FarmHand-or-base-Q4_K_M.gguf
/models/phi4-mini/FarmHand-or-base-Q4_K_M.gguf
```

Copy the example env file and fill in the real paths:

```bash
cp benchmark/candidates.example.env benchmark/candidates.env
```

Then edit `benchmark/candidates.env`.

## Run The Pair Benchmark

From the submission repo root:

```bash
source .venv/bin/activate
export LLAMA_BENCH_BIN=/absolute/path/to/llama.cpp/build/bin/llama-bench
export LLAMA_SERVER_BIN=/absolute/path/to/llama.cpp/build/bin/llama-server
export LM_EVAL_BIN=lm-eval

bash scripts/run_benchmark_pair.sh benchmark/candidates.env benchmark/results/$(date +%F)
```

This produces one folder per candidate with:

- `llama_bench.sql`
- `llama_bench.time.txt`
- `llama_server.log`
- `lm_eval/`
- `lm_eval.time.txt`
- `summary.json`

## Interpreting The Results

Read `summary.json` for each candidate. The key fields are:

- `throughput_tps`
- `throughput_peak_rss_mb`
- `mcq_accuracy`

For the first bake-off, choose the model with the best MCQ accuracy unless its RAM or throughput is clearly unsafe for the ADTC laptop profile.

## Final Submission Check

After you pick the winner and freeze `metadata.json` plus `download_model.sh`, run the official submission smoke test:

```bash
adtc-profiler run \
  --submission . \
  --mode participant \
  --output submission.json \
  --skip-accuracy
```

That run is for the submission artifact. The pair benchmark above is for choosing the artifact.
