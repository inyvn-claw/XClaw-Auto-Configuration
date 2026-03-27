---
name: bioxiv-watcher
description: Search and summarize papers from bioRxiv (biology preprints). Use when the user asks for latest biology, bioinformatics, genomics, or life science research.
---

# bioRxiv Watcher

This skill interacts with the bioRxiv API to find and summarize the latest biology and life science research papers.

## Capabilities

- **Search**: Find papers by keyword, author, or category in bioRxiv
- **Summarize**: Fetch the abstract and provide a concise summary
- **Filter by Date**: Get papers from specific time ranges
- **Category Filtering**: Biology, genomics, bioinformatics, neuroscience, etc.

## Workflow

1. Use `scripts/search_bioxiv.sh "<query>"` to get JSON results
2. Parse the JSON (look for `collection`, `title`, `abstract`, and `doi`)
3. Present the findings to the user

## API Endpoint

- bioRxiv API: `https://api.biorxiv.org/details/biorxiv/<date_range>/<cursor>`
- Search: `https://api.biorxiv.org/covid19/<query>`

## Examples

- "Search bioRxiv for CRISPR papers"
- "Find latest papers on single-cell RNA sequencing"
- "Get recent bioRxiv papers about protein folding"
- "Show me genomics research from bioRxiv this week"

## Resources

- `scripts/search_bioxiv.sh`: Direct API access script
