# ADTC Resource Guide

This is the working competition guide for the FarmHand NA submission. It turns the latest ADTC materials into a checklist we can actually use while selecting, tuning, and validating the final GGUF.

## Official Starting Points

- Submission template:
  [Africa-Deep-Tech-Foundation/adtc-2026-submission-template](https://github.com/Africa-Deep-Tech-Foundation/adtc-2026-submission-template)
- Reference profiler:
  [Africa-Deep-Tech-Foundation/adtc-profiler](https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler)
- GPU-credit application:
  [UDUTech / AGH Cloud application form](https://aghcloud.ai/philanthropy?program=3850810a-8f62-474c-b448-e204d026b189)
- Support channel:
  [ADTC Discord](https://bit.ly/ADTC_Discord)

## What The Official Material Means For This Repo

- The scored artifact is still only the submitted GGUF running through `llama.cpp`.
- `download_model.sh`, `metadata.json`, and the final weight file path have to stay perfectly aligned.
- The public profiler supports:
  - participant self-check mode
  - audit mode
  - report comparison with tolerance checks
- The published scoring formula rewards:
  - hidden-set accuracy most heavily
  - throughput up to a practical ceiling around `TPS_REFERENCE = 15.0`
  - lower peak RAM inside the 8 GB target profile
- Thermal throttling or core temperature above 85 C costs points, so cooling and sustained stability matter, not just short-run speed.
- UDUTech GPU credits are useful for training and fine-tuning, but final benchmarks must still run on the standard ADTC laptop profile.

## Recommended Study Path

1. Model formats:
   [Common AI Model Formats](https://huggingface.co/blog/ngxson/common-ai-model-formats)
   Why it matters here: explains why GGUF is the right packaging target for local `llama.cpp` inference and why memory-mapped loading matters on constrained RAM.
2. Quantization choice:
   [A Practical Guide to GGUF Quantization Selection](https://knightli.com/en/2026/04/11/llama-gguf-quantization-selection/)
   Why it matters here: supports treating `Q4_K_M` as the practical default for the laptop track.
3. Ollama orientation:
   [Ollama README](https://github.com/ollama/ollama/blob/main/README.md)
   Why it matters here: useful for quick local experiments and OpenAI-compatible serving, even though the scored submission must use `llama.cpp`.
4. Official `llama.cpp` build guide:
   [llama.cpp Linux build docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
   Why it matters here: authoritative build flags, including OpenBLAS support for Linux CPU builds.
5. CPU-only optimization discussion:
   [llama.cpp discussion 21136](https://github.com/ggml-org/llama.cpp/discussions/21136)
   Why it matters here: practical tuning ideas for 8 GB RAM systems and swap behavior.
6. Thermal monitoring:
   [Ubuntu sensors install how-to](https://help.ubuntu.com/community/SensorInstallHowto)
   Why it matters here: directly supports avoiding the ADTC thermal penalty.
7. Small-model hackathon workflow:
   [Build Small Hackathons with Cohere Models](https://huggingface.co/blog/CohereLabs/build-small-hackathon-with-cohere-models)
   Why it matters here: a compact example of offline multilingual deployment patterns that may help demo strategy.
8. African NLP datasets:
   [Masakhane NLP](https://github.com/masakhane-io/masakhane-nlp)
   Why it matters here: potential source of African-language adaptation ideas if bilingual tuning becomes worthwhile.
9. Ollama throughput benchmarking:
   [aidatatools/ollama-benchmark](https://github.com/aidatatools/ollama-benchmark)
   Why it matters here: convenient for quick iteration during exploration, though the official score path still goes through `llama.cpp`.
10. Native throughput benchmarking:
   [llama-bench README](https://github.com/ggml-org/llama.cpp/blob/master/tools/llama-bench/README.md)
   Why it matters here: this is the closest public reference for the exact benchmarking primitive used by the ADTC profiler.

## FarmHand NA Execution Plan

1. Build `llama.cpp` on an x86 Ubuntu box, preferably with OpenBLAS enabled for prompt-processing speed.
2. Benchmark the 2B-4B shortlist with this repo's pair benchmark workflow.
3. Keep the winning candidate only if it stays under the RAM ceiling, avoids thermal penalties, and wins on local agriculture accuracy.
4. Use UDUTech credits only if the best zero-tune baseline is clearly knowledge-limited.
5. Freeze the final model name, public GGUF URL, and metadata fields, then run the official participant profiler before submission.

## Repo Files Tied To This Guide

- [REPORT.md](/Users/iiyam112156/farmhand-na/REPORT.md)
- [benchmark/README.md](/Users/iiyam112156/farmhand-na/benchmark/README.md)
- [metadata.json](/Users/iiyam112156/farmhand-na/metadata.json)
- [download_model.sh](/Users/iiyam112156/farmhand-na/download_model.sh)
