# Step 1 Source-Finding Prompt

Use this prompt with a browsing-capable assistant when you want to retrieve the
real documents before filling source notes or writing dataset rows.

The immediate goal is to retrieve:

1. `SRC-DVS-SURV-2014`
2. one practical everyday-care source that helps with current gap topics:
   mastitis, retained placenta, newborn calf or kid care, urinary blockage, and eye trauma

---

## Prompt

```text
I am building source-grounded training and evaluation data for an offline livestock-health model for smallholder farmers in northern Namibia.

I need you to help me retrieve the actual source documents, not summaries.

Target 1:
- Source ID: SRC-DVS-SURV-2014
- Likely title: DVS Integrated Animal Disease Surveillance & Response Manual (2014)
- Likely origin: Namibia Directorate of Veterinary Services / Namibian government / Nammic / livestock-sector repository
- Why I need it: this is the backbone source for hard-stop and reportable-disease logic

Target 2:
- I need one practical livestock-care source for everyday husbandry and triage gaps that the DVS surveillance manual may not cover well.
- Priority topics:
  - mastitis
  - retained placenta
  - newborn calf hypothermia / colostrum / early care
  - newborn kid hypothermia / early feeding
  - urinary blockage in male goats
  - eye trauma / cloudy painful eye
- Preferred source types:
  - Namibia official extension or ministry material
  - Agribank Namibia livestock-health material
  - veterinary extension manual used in Southern Africa
  - practical livestock medicine manual or textbook chapter if local official material is not available

Your task:

1. Search for the actual documents or stable landing pages.
2. Prioritize open-access PDFs or stable official pages.
3. For each candidate, tell me:
   - exact title
   - organization / author
   - year
   - direct URL
   - whether it is a PDF, HTML page, repository record, or dead link
   - whether access is open or blocked
   - whether it looks official / primary / secondary
   - which of my target topics it covers
4. Do not summarize the disease content yet. This step is only retrieval and triage.
5. If the exact DVS manual is not directly available, give me the best available landing pages, mirrors, institutional repositories, or archive copies.
6. For the second source, recommend the single best practical-care source to retrieve first based on how well it covers the gap topics.

Output format:

A. Retrieval status for Target 1
- found / partially found / not found
- best URL
- backup URLs
- confidence
- notes on access

B. Retrieval status for Target 2
- found / partially found / not found
- best URL
- backup URLs
- confidence
- notes on access
- gap topics covered

C. Candidate table
Columns:
- source_id_candidate
- title
- org_or_author
- year
- access_type
- url
- source_strength
- likely_use

D. Recommended next action
- Which 2 documents I should download first and why

Search hints:
- "Namibia DVS Integrated Animal Disease Surveillance and Response Manual pdf"
- "Namibia Directorate of Veterinary Services surveillance response manual 2014 pdf"
- "site:nammic.com.na veterinary services manual Namibia pdf"
- "site:.na livestock health plan Namibia pdf"
- "Agribank Namibia basic livestock health plan pdf"
- "Namibia calf care mastitis retained placenta goat urinary blockage pdf"
- "Southern Africa livestock extension manual calf colostrum mastitis goat urinary obstruction pdf"

Important constraints:
- Prefer official Namibia sources first.
- Prefer direct PDFs over mentions of documents.
- If a source is only mentioned in a summary or article, that is not enough.
- If multiple versions exist, prefer the most citable and stable one.
```

---

## What Good Output Looks Like

You want the assistant to come back with:

- one concrete best link for `SRC-DVS-SURV-2014`
- one concrete best link for a practical-care source
- backup links if the first fails
- a clear note about whether each source is truly retrieved, only partially found, or still missing

Do not start filling [TEMPLATE.md](TEMPLATE.md) until you have real documents in hand.
