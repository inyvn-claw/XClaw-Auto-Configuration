---
name: journal-watcher
description: Search papers from top scientific journals (Nature, Science, Cell, PNAS, etc.). Use when user asks for latest journal publications or high-impact research.
---

# Journal Watcher

This skill searches papers from top-tier scientific journals using PubMed, CrossRef, and journal APIs.

## Supported Journals

- **Nature**: Nature, Nature Methods, Nature Machine Intelligence, Nature Communications
- **Science**: Science, Science Advances, Science Translational Medicine
- **Cell**: Cell, Cell Systems, Trends in Cell Biology
- **Other Top Journals**: PNAS, JMLR, PLOS, eLife

## Capabilities

- **Search by Journal**: Filter specific publications
- **Impact Factor Filter**: Filter by journal impact
- **Date Range**: Get recent publications
- **Citation Count**: Sort by citations

## Workflow

1. Use `scripts/search_journal.sh "<query>" <journal>`
2. Parse results (JSON/XML format)
3. Present findings

## API Sources

- PubMed: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi`
- CrossRef: `https://api.crossref.org/works`
- Europe PMC: `https://www.ebi.ac.uk/europepmc/webservices/rest/`

## Examples

- "Search Nature papers on protein structure"
- "Find Science journal articles about climate AI"
- "Get Cell papers on single-cell genomics"
- "Search PNAS for machine learning applications"

## Resources

- `scripts/search_journal.sh`: Journal paper search script
