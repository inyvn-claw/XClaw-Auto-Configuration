#!/bin/bash
# Search papers from top AI/ML conferences

QUERY="$1"
VENUE="${2:-}"
YEAR="${3:-}"
LIMIT="${4:-20}"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 <query> [venue] [year] [limit]"
    echo "Supported venues: neurips, icml, iclr, acl, cvpr, iccv, eccv, aaai, ijcai, kdd"
    echo "Example: $0 'diffusion models' neurips 2024 10"
    exit 1
fi

# Build search query
SEARCH_QUERY=$(echo "$QUERY" | sed 's/ /+/g')

# Use PapersWithCode API as primary source
if [ -n "$VENUE" ]; then
    # Search with venue filter
    URL="https://paperswithcode.com/api/v1/papers/?q=${SEARCH_QUERY}&venue=${VENUE}&items_per_page=${LIMIT}"
else
    # General search
    URL="https://paperswithcode.com/api/v1/papers/?q=${SEARCH_QUERY}&items_per_page=${LIMIT}"
fi

# Fetch data
curl -sL "$URL" | python3 -m json.tool 2>/dev/null || curl -sL "$URL"
