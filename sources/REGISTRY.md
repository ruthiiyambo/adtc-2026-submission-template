# Source Registry — FarmHand NA

Every claim in `eval/mcq/` and `data/finetune/` cites one or more of these IDs.
**Cite the primary document, not the research pack.** The two research packs are
logged at the bottom as syntheses to verify against, not to cite directly.

Tier key: T1 = northern-Namibia-specific · T2 = Namibia national/official ·
T3 = Southern Africa regional · T4 = general veterinary reference.

| ID | Source | Tier | Type / reliability | Status |
|----|--------|------|--------------------|--------|
| SRC-DVS-SURV-2014 | DVS *Integrated Animal Disease Surveillance & Response Manual* (2014) | T2 (some T1 detail) | Official govt surveillance/response manual — **primary workhorse**; high authority (some embedded refs are older) | ☐ retrieve primary PDF (nammic/LLPBN) |
| SRC-AHA-REG-2018 | *Animal Health Act Regulations, 2018* (GN 358/2018, Gaz. 6803) | T2 | Current legal text — reporting duties & control measures | ✔ extracted into `sources/SRC-AHA-REG-2018.md` |
| SRC-GN180-2013 | *Declaration of Notifiable Diseases* (GN 180/2013, Gaz. 5239) | T2 | Primary legal instrument — the notifiable list | ✔ extracted into `sources/SRC-GN180-2013.md` |
| SRC-DVS-POSTERS-2021 | DVS *Notifiable Animal Disease Posters* (2021) | T2 | Govt farmer-facing posters (FMD/CBPP/PPR/bTB) | ☐ retrieve (nammic.com.na) |
| SRC-AGRIBANK-HP | Agribank *Basic Livestock Health Plan* (Ngaruka) | T2 | Govt-bank extension — vaccination calendar, bloat first-aid | ☐ retrieve (server error on fetch — get direct) |
| SRC-FAO-ND-Y5162E | FAO *Controlling Newcastle Disease in Village Chickens* | T4 (built for this context) | FAO manual — open access | ☐ retrieve (fao.org y5162e) |
| SRC-FAO-POULTRY-Y5169E | FAO *Small-scale poultry production* | T4 | FAO manual — open access | ☐ retrieve (fao.org y5169e) |
| SRC-ACIAR-ND-2002 | Alders et al. ND village-chicken training manual (ACIAR) | T3 | Practitioner manual, African village poultry | ☐ retrieve |
| SRC-EIKI-2022 | Eiki et al., ethnoveterinary plants, Omusati/Kunene (*Front. Vet. Sci.*) | T1 | Peer-reviewed — **ethnobotanical/epidemiological, NOT clinical triage** | ✔ local PDF provided in QuickFix |
| SRC-PETRUS-2011 | Petrus et al., indigenous chicken N. communal Namibia (LRRD) | T1 | Peer-reviewed rural-production — local poultry context | ☐ retrieve (decode error last fetch) |
| SRC-WOAH-PPR-2025 | WOAH Africa PPR-free status workshop note (2025) | T3 | Intergovernmental — **current** PPR status (supersedes 2014 wording) | ☐ retrieve |
| SRC-BARANDONGO-2023 | Barandongo et al., anthrax spore persistence, Etosha (*Sci. Total Environ.*) | T1 | Peer-reviewed — resolves the 50yr-vs-~10yr conflict | ✔ open access |
| SRC-HIKUFE-2019 | Hikufe et al., rabies epidemiology Namibia (*PLoS NTD*) | T2 | Peer-reviewed, DVS-authored | ✔ local PDF provided in QuickFix |

## Research syntheses (verify against primaries — do NOT cite directly)

- `sources/research/pack1_disease_kb.md` — sourced KB (26 conditions). Marked synthesis.
- `sources/research/pack2_evidence_pack.md` — DVS-manual-focused evidence pack. Marked synthesis.

## Retrieval queue (do these to upgrade citations from synthesis → primary)

1. **SRC-DVS-SURV-2014** — the single highest-value pull; backs most of the eval set.
2. `SRC-GN180-2013` + `SRC-AHA-REG-2018` — legal backbone for the "report, don't treat" hard-stop.
3. `SRC-AGRIBANK-HP` — bloat first-aid + vaccination calendar.
4. `SRC-FAO-ND-Y5162E` — Newcastle, village-poultry.
