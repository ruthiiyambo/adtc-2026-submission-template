# FarmHand NA x86 Benchmark Workflow

This workflow is for the real model bake-off on a participant-style Ubuntu machine. It compares candidate GGUFs on the three things that matter now:

1. `llama-bench` generation throughput.
2. Peak RSS during the throughput run.
3. Local domain accuracy on the FarmHand NA MCQ seed set.

It is intentionally CPU-only for the comparison run so the numbers are stable and easy to compare across x86 machines. If you later want to test integrated-GPU offload, do that as a separate experiment, not as the baseline comparison.

The throughput leg is ADTC-aligned, not byte-for-byte identical to the public profiler implementation. The public profiler source calls `llama-bench` with the `-p 512 -n 128` test shape and optional thread count. This repo's comparison script keeps that shape but also pins the run to CPU-only and repeats it in a controlled way so your candidate bake-off is stable on the Ubuntu box.

The official ADTC scoring material now also makes two constraints explicit:

- throughput has diminishing returns once you are around `TPS_REFERENCE = 15.0`
- thermal throttling or core temperature above 85 C costs points

That means this bake-off should optimize for sustained accuracy, memory safety, and repeatable thermals, not just the single fastest run.

## Shortest Path: One-Model x86 VM Smoke

If your only goal is to validate the current submission candidate on a real
x86 Ubuntu VM, use this path.

1. Provision an Ubuntu 22.04 `x86_64` VM with `4 vCPU / 8 GB RAM`.
2. Clone this repo onto the VM.
3. Install packages:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake pkg-config time python3.11 python3.11-venv curl git libopenblas-dev lm-sensors
```

4. Put `llama.cpp` under the repo root and build the required binaries:

```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cmake -B build -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS
cmake --build build --config Release -t llama-bench -t llama-server -t llama-perplexity
cd ..
```

5. Create the Python environment used by the helper:

```bash
python3.11 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git"
```

6. Put the model at the expected cache path:

```text
/models/phi4-mini/Phi-4-mini-instruct-Q4_K_M.gguf
```

7. Run the whole smoke test with one command:

```bash
bash scripts/run_x86_vm_smoke.sh
```

What success looks like:

- `submission.json` is written in the repo root.
- `submission.log` contains `✓ wrote .../submission.json`.
- The helper prints:
  - `throughput.tokens_per_second_generation=...`
  - `memory.peak_rss_mb=...`

For this first pass, the only numbers that matter are:

- Is `memory.peak_rss_mb` safely below `7000`?
- Is `throughput.tokens_per_second_generation` around `15` or better?

Observed result from the first successful participant-style smoke test on July 8, 2026:

- machine: Google Cloud Ubuntu 22.04.5 LTS `x86_64`, `4 vCPU / 8 GB RAM`
- model: `Qwen3-4B-Q4_K_M`
- `throughput.tokens_per_second_generation=8.46`
- `memory.peak_rss_mb=4380.61`

Observed result from the completed side-by-side benchmark on July 9, 2026:

- `Qwen3-4B-Q4_K_M`
  - `throughput_tps=11.3916`
  - `throughput_peak_rss_mb=3745.64`
  - `mcq_eval_peak_rss_mb=7121.34`
  - `mcq_accuracy=0.75`
- `Phi-4-mini-instruct-Q4_K_M`
  - `throughput_tps=12.068`
  - `throughput_peak_rss_mb=3887.45`
  - `mcq_eval_peak_rss_mb=6716.28`
  - `mcq_accuracy=0.85`

Takeaway: the current repo default is now `Phi-4-mini-instruct-Q4_K_M` because it won the local side-by-side benchmark on accuracy, speed, and MCQ memory headroom. The next highest-value step is a fresh participant-style profiler smoke test for Phi on the same VM recipe.

## Next Run: Phi-4-mini Side By Side

Once the Qwen smoke test is done, keep the same VM recipe and compare a second
candidate instead of recreating the whole environment.

1. Put the Phi GGUF at a stable path such as:

```text
/models/phi4-mini/Phi-4-mini-instruct-Q4_K_M.gguf
```

2. Fill `benchmark/candidates.env` with both candidates:

```bash
QWEN_LABEL=qwen3_4b_q4km
QWEN_MODEL=/models/qwen3-4b/Qwen3-4B-Instruct-Q4_K_M.gguf
QWEN_PORT=8081

PHI_LABEL=phi4_mini_q4km
PHI_MODEL=/models/phi4-mini/Phi-4-mini-instruct-Q4_K_M.gguf
PHI_PORT=8082

THREADS=4
THREADS_BATCH=4
CTX_SIZE=2048
BATCH_SIZE=2048
UBATCH_SIZE=512
REPETITIONS=5

MCQ_CTX_SIZE=512
MCQ_BATCH_SIZE=512
MCQ_UBATCH_SIZE=128
MCQ_PARALLEL=4
```

3. Make sure the local `llama.cpp` binaries are on `PATH`:

```bash
export PATH="$PWD/llama.cpp/build/bin:$PATH"
```

4. Run the repo pre-flight again:

```bash
bash scripts/check_benchmark_prereqs.sh benchmark/candidates.env
```

5. Run the pair comparison:

```bash
bash scripts/run_benchmark_pair.sh benchmark/candidates.env benchmark/results/$(date +%F)-qwen-vs-phi
```

6. Read the two `summary.json` files under the output folder and compare:

- `throughput_tps`
- `throughput_peak_rss_mb`
- `mcq_accuracy`

On the `4 vCPU / 8 GB` VM, keep the MCQ scorer on a smaller context and batch
than the throughput leg. Qwen reached roughly `7.36 GiB` RSS and was killed
when the native scorer inherited the larger `2048 / 2048 / 512` settings.

The pair benchmark now uses `llama-perplexity --multiple-choice` for the MCQ
leg instead of `llama-server` + `lm-eval`. That is more stable for GGUF models
because it scores the choice continuations natively inside `llama.cpp` rather
than relying on OpenAI-style server logprob compatibility.

Note: unlike the participant smoke helper, the pair benchmark scripts need GNU
`time -v`, so the Ubuntu `time` package is part of the required VM setup.

## What The Scripts Do

- [scripts/run_candidate_benchmark.sh](/Users/iiyam112156/farmhand-na/scripts/run_candidate_benchmark.sh:1)
  - Runs `llama-bench` on one model with the ADTC-aligned `-p 512 -n 128` shape.
  - Measures peak RSS for that run with GNU `/usr/bin/time -v`.
  - Converts the FarmHand NA MCQ seed set into the native binary multiple-choice format expected by `llama-perplexity`.
  - Runs `llama-perplexity --multiple-choice` on CPU only for native MCQ scoring with separate MCQ memory knobs.
  - Saves raw outputs plus a normalized `summary.json`.
- [scripts/build_llama_multiple_choice.py](/Users/iiyam112156/farmhand-na/scripts/build_llama_multiple_choice.py:1)
  - Converts `eval/mcq/farmhand_na_mcq_seed.jsonl` into the binary task format used by `llama-perplexity --multiple-choice`.
- [scripts/run_lm_eval_gguf_compat.py](/Users/iiyam112156/farmhand-na/scripts/run_lm_eval_gguf_compat.py:1)
  - Keeps the older GGUF HTTP eval workaround available, but it is no longer the default path for the pair benchmark.
- [scripts/run_benchmark_pair.sh](/Users/iiyam112156/farmhand-na/scripts/run_benchmark_pair.sh:1)
  - Runs the single-model script twice using one env file for `Qwen3-4B` and `Phi-4-mini`.
- [scripts/summarize_benchmark.py](/Users/iiyam112156/farmhand-na/scripts/summarize_benchmark.py:1)
  - Parses raw SQL, JSON, and GNU time outputs into one compact summary per model.
- [scripts/run_x86_vm_smoke.sh](/Users/iiyam112156/farmhand-na/scripts/run_x86_vm_smoke.sh:1)
  - Minimal one-model participant smoke test for an Ubuntu x86 VM.
  - Runs `download_model.sh`, the repo pre-flight, and then `adtc-profiler`.
  - Prints the two fields you care about most: generation throughput and peak RSS.

## Prerequisites On The Ubuntu Box

Install system packages:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake pkg-config time python3.11 python3.11-venv curl git libopenblas-dev lm-sensors
```

Build `llama.cpp` tools:

```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cmake -B build -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS
cmake --build build --config Release -t llama-bench -t llama-server -t llama-perplexity
```

Why OpenBLAS: the upstream `llama.cpp` build guide notes that BLAS support can improve prompt processing for larger batch sizes, and the public ADTC profiler uses a prompt-processing shape of `-p 512 -n 128`. It does not usually improve token generation speed directly, but it is still worth enabling for like-for-like prep on Ubuntu CPU systems.

Create a Python environment and install the benchmark-side Python tools:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git"
```

## macOS Smoke Test Only

If you are only doing a local smoke test on macOS, do not use the Ubuntu `apt-get`
steps or the Linux OpenBLAS build flags unchanged.

- ADTC-comparable numbers still need an x86 Ubuntu machine.
- `adtc-profiler` requires Python `>= 3.11`. The stock macOS `python3` can be too old.
- The benchmark script needs GNU `time`, which Homebrew installs as `gtime`.
- On macOS, `llama.cpp` can use the Accelerate framework by default, so you do not
  need the Linux `GGML_BLAS=ON` + `OpenBLAS` recipe for a smoke test.

Suggested macOS-only setup:

```bash
brew install cmake gnu-time python@3.11

cd llama.cpp
cmake -B build
cmake --build build --config Release -t llama-bench -t llama-server -t llama-perplexity
cd ..

python3.11 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git"
export TIME_BIN=gtime
export LLAMA_BENCH_BIN=/absolute/path/to/llama.cpp/build/bin/llama-bench
export LLAMA_SERVER_BIN=/absolute/path/to/llama.cpp/build/bin/llama-server
export LLAMA_PERPLEXITY_BIN=/absolute/path/to/llama.cpp/build/bin/llama-perplexity
export PATH="$PWD/llama.cpp/build/bin:$PATH"
```

For the official `adtc-profiler` smoke test, `PATH` is the important one:

```bash
export PATH="$PWD/llama.cpp/build/bin:$PATH"
export LLAMA_ARG_N_GPU_LAYERS=0
export LLAMA_ARG_DEVICE=none
```

Common failure cases on macOS:

- `apt-get: command not found`
  You are on macOS, not Ubuntu.
- `Package 'adtc-profiler' requires a different Python: 3.9.x not in '>=3.11'`
  Create the venv with `python3.11`, not the system `python3`.
- `BLAS not found`
  That usually means you applied the Linux OpenBLAS flags on macOS without installing and wiring a BLAS library. For a smoke test, use the default macOS build shown above.
- `model file not found: /absolute/path/to/...`
  Replace the placeholder GGUF path with the real local file path.

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

## Cheap Pre-flight Check

Before you spend money or time on the Ubuntu box, run the repo-side sanity
check:

```bash
bash scripts/check_benchmark_prereqs.sh
```

Or, if you already created and filled the real env file:

```bash
bash scripts/check_benchmark_prereqs.sh benchmark/candidates.env
```

This checks the benchmark scripts, the expected MCQ seed file path, and, when
`candidates.env` exists, the two GGUF paths plus the basic runner knobs and
port values.

## Run The Pair Benchmark

From the submission repo root:

```bash
source .venv/bin/activate
export LLAMA_BENCH_BIN=/absolute/path/to/llama.cpp/build/bin/llama-bench
export LLAMA_SERVER_BIN=/absolute/path/to/llama.cpp/build/bin/llama-server
export LLAMA_PERPLEXITY_BIN=/absolute/path/to/llama.cpp/build/bin/llama-perplexity

bash scripts/run_benchmark_pair.sh benchmark/candidates.env benchmark/results/$(date +%F)
```

This produces one folder per candidate with:

- `llama_bench.sql`
- `llama_bench.time.txt`
- `mcq_eval.prepare.txt`
- `mcq_eval.stdout.txt`
- `mcq_eval.time.txt`
- `summary.json`

The native MCQ scorer uses these env vars when present:

- `MCQ_CTX_SIZE`
- `MCQ_BATCH_SIZE`
- `MCQ_UBATCH_SIZE`
- `MCQ_PARALLEL`

## Interpreting The Results

Read `summary.json` for each candidate. The key fields are:

- `throughput_tps`
- `throughput_peak_rss_mb`
- `mcq_accuracy`

For the first bake-off, choose the model with the best MCQ accuracy unless its RAM or throughput is clearly unsafe for the ADTC laptop profile.

## Final Submission Check

After you pick the winner and freeze `metadata.json` plus `download_model.sh`, run the official submission smoke test:

```bash
export PATH=/absolute/path/to/llama.cpp/build/bin:$PATH
bash download_model.sh

adtc-profiler run \
  --submission . \
  --mode participant \
  --output submission.json \
  --skip-accuracy
```

Notes:

- `adtc-profiler` looks up `llama-bench` on `PATH`; it does not read `LLAMA_BENCH_BIN`.
- `bash download_model.sh` must populate the exact repo-local path from `metadata.json -> _runtime.model_path` before the profiler run.

If you later receive an organizer-produced audit JSON, compare it against your participant run:

```bash
adtc-profiler compare submission.json audit.json --output verdict.json
```

That run is for the submission artifact. The pair benchmark above is for choosing the artifact.
