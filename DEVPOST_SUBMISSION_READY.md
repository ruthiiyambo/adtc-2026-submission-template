# Devpost Submission Pack - FarmHand NA

Use this as your direct source while filling Devpost fields.

## 1) Project Story (paste into Devpost "About the project")

## Inspiration

FarmHand NA was inspired by a common problem in northern Namibia: when livestock become sick, farmers often need to make urgent decisions before a veterinarian or extension officer can be reached. In many communities, connectivity is unreliable, transport is expensive, and expert help is not immediately available. I wanted to build a small offline AI assistant that helps farmers and extension workers reason through likely causes, safe first actions, and clear red-flag signs that require urgent referral.

## What it does

FarmHand NA is an offline livestock-health triage assistant designed for low-resource settings. A user describes symptoms in plain language and receives structured guidance on:

- likely causes
- safe first actions
- warning signs that require same-day or urgent veterinary help

The current version is English-first and focused on northern Namibian livestock use cases, with a longer-term goal of bilingual support including a verified Oshindonga written workflow.

## How I built it

I built the project around the Africa Deep Tech Challenge laptop constraints:

- llama.cpp runtime
- GGUF quantized weights
- fully offline inference
- Ubuntu x86_64 target profile with 4 vCPU and 8 GB RAM

I benchmarked multiple small open models and compared them on memory use, generation speed, and a local agriculture multiple-choice evaluation set. After side-by-side testing, I selected Phi-4-mini-instruct-Q4_K_M as the current submission candidate because it gave the best balance of local task accuracy, memory headroom, and throughput on the target machine.

I also built a lightweight evaluation workflow for repeatable x86 benchmarking, participant-style smoke tests, and local multiple-choice scoring.

## Challenges I ran into

A major challenge was validating performance on the actual target hardware profile, not just a local laptop. Apple Silicon runs were useful for iteration, but not reliable enough for final claims, so I validated on Ubuntu x86_64.

Another challenge was evaluation compatibility. Some server-style logprob benchmark paths were inconsistent with GGUF workflows, so I switched to a more stable native llama.cpp multiple-choice scoring path. I also tuned evaluation settings carefully to avoid memory spikes on the 8 GB target profile.

## Accomplishments I am proud of

I am proud that the project now runs fully offline, fits within the RAM budget on the target machine, and has a repeatable benchmark workflow for comparing candidate models. I am also proud that it is grounded in a real African agriculture use case rather than a generic chatbot demo.

## What I learned

I learned that model selection under tight hardware constraints is as much about evaluation discipline as model quality. Small differences in runtime configuration, memory behavior, and benchmark method can significantly change outcomes, so reproducible testing matters as much as raw model capability.

## What is next

Next, I plan to expand validated bilingual coverage, improve local livestock-health evaluation data, and continue optimizing response quality for low-literacy, field-first use.

## 2) Built With (Devpost tags)

Use these primary tags first (tight, high-signal set):

- llama.cpp
- gguf
- phi-4-mini
- q4_k_m
- offline-ai
- local-llm
- edge-ai
- on-device-inference
- agriculture
- livestock
- namibia
- ubuntu

If Devpost allows more and you want extras, add these in order:

- quantization
- python
- openblas
- x86_64

## 3) Try It Out Links

Use these links in Devpost:

- Source code: https://github.com/ruthiiyambo/adtc-2026-submission-template
- Submission preview: https://devpost.com/software/farmhand-na
- Optional local demo instruction: https://github.com/ruthiiyambo/adtc-2026-submission-template#optional-local-demo-ui

## 4) Video Demo Link

Add your 2-minute demo video URL here before submit.

Recommended title:
FarmHand NA - Offline Livestock Triage Assistant for Northern Namibia (ADTC 2026)

## 5) Profiler Scores to Enter (Self-Reported)

Use your participant-style x86 run values:

- tokens_per_second_generation = 6.51
- peak_rss_mb = 3910.79

Using official formula:

- Sperf = min(TPS / 15.0, 1.0) * 100 = 43.40
- Seff = max(0, (7.0 - peak_rss_gb) / 7.0) * 100 = 44.13

Enter:

- Self-Reported Profiler Performance Score (Sperf): 43.40
- Self-Reported Profiler Efficiency Score (Seff): 44.13

## 6) Final 10-Minute Submit Checklist

- Repo is public.
- metadata.json is fully populated (team_id farmhand-na, 2 prompts, model path).
- download_model.sh downloads the same GGUF referenced by metadata.
- submission.json exists from a participant-style run.
- Devpost Project Story pasted.
- Built With tags added.
- Video link added.
- Sperf and Seff entered in separate fields.
- Click Finalization -> Submit.
