---
name: conference-watcher
description: Search papers from top AI/ML conferences (NeurIPS, ICML, ICLR, ACL, CVPR, etc.). Use when user asks for latest conference papers or specific venue research.
---

# Conference Watcher

This skill searches papers from top-tier AI/ML conferences using multiple sources including OpenReview, PapersWithCode, and conference websites.

## Supported Conferences

- **ML**: NeurIPS, ICML, ICLR
- **NLP**: ACL, EMNLP, NAACL, COLING
- **CV**: CVPR, ICCV, ECCV
- **AI**: AAAI, IJCAI
- **Data Mining**: KDD, WWW

## Capabilities

- **Search by Venue**: Find papers from specific conferences
- **Search by Year**: Filter by conference year
- **Keyword Search**: Search within conference papers
- **Get Bibtex**: Retrieve citation information

## Workflow

1. Use `scripts/search_conference.sh "<query>" <venue> <year>`
2. Parse results (JSON format)
3. Present findings

## API Sources

- OpenReview: `https://api.openreview.net/notes`
- PapersWithCode: `https://paperswithcode.com/api/v1/papers/`

## Examples

- "Find NeurIPS 2024 papers on reinforcement learning"
- "Search ICML papers about diffusion models"
- "Get latest ICLR papers on LLM reasoning"
- "Find CVPR papers on multimodal learning"

## Resources

- `scripts/search_conference.sh`: Conference paper search script
