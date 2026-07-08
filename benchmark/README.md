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

If your only goal is to de-risk the submission with one Qwen run on a real
x86 Ubuntu VM, use this path.

1. Provision an Ubuntu 22.04 `x86_64` VM with `4 vCPU / 8 GB RAM`.
2. Clone this repo onto the VM.
3. Install packages:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake python3.11 python3.11-venv curl git libopenblas-dev lm-sensors
```

4. Put `llama.cpp` under the repo root and build the two required binaries:

```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cmake -B build -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS
cmake --build build --config Release -t llama-bench -t llama-server
cd ..
```

5. Create the Python environment used by the helper:

```bash
python3.11 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git"
.venv/bin/pip install "git+https://github.com/EleutherAI/lm-evaluation-harness.git"
```

6. Put the model at the expected cache path:

```text
/models/qwen3-4b/Qwen3-4B-Instruct-Q4_K_M.gguf
```

7. Copy the example env exactly once:

```bash
cp benchmark/candidates.example.env benchmark/candidates.env
```

8. Run the whole smoke test with one command:

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
- [scripts/run_x86_vm_smoke.sh](/Users/iiyam112156/farmhand-na/scripts/run_x86_vm_smoke.sh:1)
  - Minimal one-model participant smoke test for an Ubuntu x86 VM.
  - Runs `download_model.sh`, the repo pre-flight, and then `adtc-profiler`.
  - Prints the two fields you care about most: generation throughput and peak RSS.

## Prerequisites On The Ubuntu Box

Install system packages:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake python3.11 python3.11-venv curl git libopenblas-dev lm-sensors
```

Build `llama.cpp` tools:

```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cmake -B build -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS
cmake --build build --config Release -t llama-bench -t llama-server
```

Why OpenBLAS: the upstream `llama.cpp` build guide notes that BLAS support can improve prompt processing for larger batch sizes, and the public ADTC profiler uses a prompt-processing shape of `-p 512 -n 128`. It does not usually improve token generation speed directly, but it is still worth enabling for like-for-like prep on Ubuntu CPU systems.

Create a Python environment and install the two benchmark-side Python tools:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git"
pip install "git+https://github.com/EleutherAI/lm-evaluation-harness.git"
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
cmake --build build --config Release -t llama-bench -t llama-server
cd ..

python3.11 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git"
pip install "git+https://github.com/EleutherAI/lm-evaluation-harness.git"

export TIME_BIN=gtime
export LLAMA_BENCH_BIN=/absolute/path/to/llama.cpp/build/bin/llama-bench
export LLAMA_SERVER_BIN=/absolute/path/to/llama.cpp/build/bin/llama-server
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

This checks the benchmark scripts, the `lm-eval` task wiring, the expected MCQ
file path, and, when `candidates.env` exists, the two GGUF paths plus the basic
runner knobs and port values.

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
