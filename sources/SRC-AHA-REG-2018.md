# SRC-AHA-REG-2018

## Source Metadata

- `source_id`: `SRC-AHA-REG-2018`
- `title`: `Animal Health Regulations`
- `author_or_org`: `Ministry of Agriculture, Water and Forestry, Republic of Namibia`
- `year`: `2018`
- `source_type`: `government regulation`
- `tier`: `T2`
- `status`: `extracted`
- `local_file`: `/Users/iiyam112156/Desktop/QuickFix/Animal Health Act 1 of 2011-Regulations 2018-358.pdf`
- `url_or_origin`: `QuickFix local PDF; Government Notice 358 of 2018 (GG 6803)`
- `pages_or_sections_used`:
  - `PDF p.17-18, reg. 16-18`
  - `PDF p.24, reg. 33`
  - `PDF p.27-30, reg. 44-52`
  - `PDF p.36, reg. 71`
  - `PDF p.40, reg. 84-85`
  - `PDF p.58, reg. 156`
  - `PDF p.63, Schedule 3`

## Why This Source Matters

- This is the main legal backbone for "report, isolate, do not move, do not self-treat" behavior.
- It is strong enough for:
  - hard-stop behavior
  - gold MCQ labeling on legal/reporting duties
  - movement-control logic for suspected notifiable diseases
- Main limitation:
  - it is legal/control text, not a clinical triage manual
  - use it to justify reporting, isolation, movement restriction, and official control measures
  - pair it with clinical or husbandry sources for bedside signs and first-aid guidance

## Condition Coverage

- species: `multi-species`
- production context: `national livestock regulation; applies to communal and commercial systems`
- seasonality if mentioned: `none as a primary organizing frame`
- geography if mentioned: `national; Schedule 3 explicitly names northern FMD control-zone regions including Ohangwena, Oshana, Omusati, part of Oshikoto, part of Kunene, Kavango East, and Kavango West`
- diseases or syndromes covered:
  - notifiable-disease reporting and isolation duties
  - rabies
  - anthrax
  - brucellosis
  - bovine tuberculosis
  - foot and mouth disease
  - contagious bovine pleuropneumonia
  - Newcastle disease
  - sheep scab
  - African swine fever
  - Rift Valley fever
  - other regulated animal diseases listed in the regulations

## Extracted Facts

| Field | Notes from source |
|---|---|
| Key signs / pattern | This is not a symptom guide. It activates when an animal is infected or suspected of being infected with a notifiable disease. |
| Most likely cause(s) | Not applicable as a standalone diagnostic source. |
| Safe first action(s) | A notifiable disease notification may be made to a veterinary official or police officer; the owner must isolate a suspected animal, prevent access, and prevent contact with other susceptible animals. |
| Referral or emergency cues | Suspected notifiable disease triggers same-day official reporting and control. In rabies exposures, veterinary officials must advise in-contact persons to seek medical attention immediately. |
| Reporting or legal duty | Reg. 16 sets the duty to report and isolate; reg. 17 allows veterinary officials to order confinement, isolation, cleansing, disinfection, vaccination, testing, and treatment. |
| Zoonotic concern | Rabies rules require immediate reporting, secure confinement or destruction, and notification to medical personnel of exposed people. |
| What not to do | Do not allow access to suspected infected animals; do not move cloven-hoofed animals/products/restricted material across FMD zones without permit; do not treat CBPP without authorisation. |
| Prevention or follow-up | Anthrax vaccination is compulsory for cattle older than three months every 12 months; dogs/cats/pets require rabies vaccination; owners in restricted/notifiable situations must keep a register. |

## Evidence Anchors

| Claim you may use | Page / section / anchor |
|---|---|
| Suspected notifiable disease can be reported to a veterinary official or police officer | `PDF p.17, reg. 16(1)-(3)` |
| Owner must isolate a suspected infected animal and prevent access by people and other animals | `PDF p.17, reg. 16(5)(a)-(c)` |
| People who handled infected/suspected animals or carcasses must disinfect themselves, clothing, and equipment | `PDF p.18, tail end of reg. 16` |
| Veterinary officials may order confinement, isolation, cleansing, disinfection, vaccination, testing, and treatment | `PDF p.18, reg. 17(1)` |
| Owners in restricted/notifiable situations must keep a notifiable disease register | `PDF p.24, reg. 33(1)-(5)` |
| Suspected rabies: owner must notify a veterinary official and isolate/securely confine or kill the animal | `PDF p.27, reg. 44` |
| Veterinary official must advise in-contact persons to seek medical attention after suspected rabies exposure | `PDF p.28, reg. 45(c)-(d)` |
| Cattle owners must vaccinate cattle older than three months annually against anthrax; suspected anthrax must be reported | `PDF p.36, reg. 71(1)-(3)` |
| Movement of cloven-hoofed animals/products/restricted material between FMD zones requires a permit | `PDF p.40, reg. 84(1)` |
| Suspected or confirmed FMD requires immediate movement restrictions, roadblocks, searches, and disinfection | `PDF p.40, reg. 85(a)-(c)` |
| CBPP treatment is prohibited unless authorised by the Chief Veterinary Officer | `PDF p.58, reg. 156(1)` |
| Northern regions including Omusati and Oshana are in the FMD Protection Zone | `PDF p.63, Schedule 3 item 2` |

## Local Applicability Check

- Does this clearly fit northern Namibia smallholder conditions?
  - Yes for legal duties, official reporting, movement restrictions, and FMD-zone context.
- If not, what needs confirmation before it becomes gold?
  - Clinical-sign interpretation still needs a practical-care or surveillance source.
- Are there any wording changes needed so the example sounds like a real farmer?
  - Translate "notifiable disease" into plain language such as "a disease that must be reported immediately."
  - Translate "movement permit" into concrete farmer actions like "do not move, sell, or take to auction."

## Dataset Decision

- `dataset_readiness`: `gold_ready`
- `recommended_source_slot_primary`: `SRC-AHA-REG-2018`
- `recommended_source_slot_secondary`: `SRC-GN180-2013`

## Candidate SFT Rows

1. `species`: `cattle`
   `instruction idea`: `Several cattle are drooling, lame, and have mouth sores. What should the owner do first?`
   `target behavior`: `Do not move the herd, isolate affected stock, and report urgently because a notifiable disease such as FMD must be ruled out.`

2. `species`: `multi-species`
   `instruction idea`: `What should I do if I suspect a notifiable disease in my animals?`
   `target behavior`: `Report to a veterinary official immediately, isolate the animal, and prevent access by people and susceptible animals.`

3. `species`: `cattle`
   `instruction idea`: `Can I treat suspected lung sickness on my own?`
   `target behavior`: `Do not self-treat suspected CBPP unless authorised by the Chief Veterinary Officer.`

## Candidate MCQs

1. `focus`: `reporting`
   `question idea`: `Several cattle on communal grazing suddenly drool, have mouth sores, and are lame. What is the safest response?`
   `gold concept`: `Restrict movement and report urgently because a notifiable disease must be ruled out.`
   `status`: `sourced`

2. `focus`: `hard_stop`
   `question idea`: `A farmer wants to move cattle from a northern control-zone area after signs compatible with FMD appear. What should happen first?`
   `gold concept`: `Movement stops and veterinary reporting/control starts immediately.`
   `status`: `sourced`

## Notes For Farmer Wording

- local phrase or wording to reuse:
  - `do not move them`
  - `do not take them to auction`
  - `call the state vet now`
- confusing or formal phrasing to avoid:
  - `notifiable disease`
  - `restricted material`
  - `in-contact persons`
- follow-up question a farmer would likely ask:
  - `Can I still sell or move the animals if only one looks sick?`

## Promotion Checklist

- [x] source is logged in `sources/REGISTRY.md`
- [x] important claims have page or section anchors
- [ ] SFT wording is not copied from eval wording
- [ ] MCQ wording is not copied from training wording
- [x] risky advice has official or primary support
- [x] item is marked `sourced`, `partial`, or `gap` honestly
