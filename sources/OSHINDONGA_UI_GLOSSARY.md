# Oshindonga UI Glossary

This note records the current language choice for the FarmHand NA demo UI.

## Current decision

- Base written variety for v1 bilingual UI: `Oshindonga`
- Submission scoring language focus: `English-first`
- Practical rule: do not freely mix Oshindonga and Oshikwanyama in the same UI copy.
- If a word is only verified at the broader `Oshiwambo` family level, mark it as such and keep it out of critical symptom wording until native-speaker review.

## What the project says now

- The repo still keeps `metadata.json` language scope at `["en"]` because the scored submission remains English-first.
- The project description now names `Oshindonga` as the planned written variety for the bilingual demo.

## Starter terms we can safely discuss

These are useful as a first-pass glossary for UI labels, greetings, and short helper text.

| English | Term | Confidence | Notes | Source |
|---|---|---|---|---|
| Oshindonga language | `Oshindonga` | High | Standard written variety used in Namibia. | `Ndonga` overview |
| Ovambo person | `Omuwambo` | Medium | Ndonga endonym form reported at the Oshiwambo family level. | `Ovambo language` overview |
| Ovambo people | `Aawambo` | Medium | Ndonga plural form reported at the Oshiwambo family level. | `Ovambo language` overview |
| listen | `pulakena` | Medium | Reported as the Ndonga form in a dialect comparison note. Useful for future helper text. | `Kwambi dialect` vocabulary note |
| hello | `Wa aluka!` | Low-medium | Reported as an Oshiwambo example, not separately verified here as Oshindonga-only. | `Oshiwambo` examples page |
| good morning | `Wa shilwa?` | Low-medium | Same caution as above. | `Oshiwambo` examples page |
| how are you? | `Ou li tutu nawa?` | Low-medium | Same caution as above. | `Oshiwambo` examples page |
| thank you | `Nda pandula` | Low-medium | Same caution as above. | `Oshiwambo` examples page |
| yes | `Heeno` | Low-medium | Same caution as above. | `Oshiwambo` examples page |
| no | `Aaye` | Low-medium | Same caution as above. | `Oshiwambo` examples page |
| goodbye | `Enda nawa` | Low-medium | Same caution as above. | `Oshiwambo` examples page |

## Words to avoid localizing yet

Do not guess these yet without a better Oshindonga source or native-speaker review:

- livestock symptom words such as `diarrhea`, `bloat`, `fever`, `weak`, `dehydration`
- clinical warning phrases such as `urgent help`, `same-day referral`, `outbreak`
- treatment and medicine terms
- animal-type labels if we cannot verify the exact everyday local word choice

## Recommended UI strategy

For the next UI pass:

1. Keep symptom and action text in simple English.
2. Add small Oshindonga touches in low-risk places first:
   - greeting text
   - helper note
   - thank-you / exit wording
3. Only translate core farm-health content after we review stronger Oshindonga references or native-speaker feedback.

## Source notes

Background pages used to assemble this starter list:

- `Ndonga` overview: https://en.wikipedia.org/wiki/Ndonga
- `Ovambo language` overview: https://en.wikipedia.org/wiki/Ovambo_language
- `Kwambi dialect` note with Ndonga comparison vocabulary: https://en.wikipedia.org/wiki/Kwambi_dialect
- `Oshiwambo` examples page: https://de.wikipedia.org/wiki/Oshivambo

Further references to consult before deeper localization:

- Derek Fivaz, `A Reference Grammar of Oshindonga`
- Toivo Emil Tirronen, `Ndonga-English Dictionary`
- Dawie J. Fourie, `Oshiwambo: Past, Present and Future`
