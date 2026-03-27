#!/bin/bash
# Search bioRxiv papers using their API

QUERY="$1"
LIMIT="${2:-20}"
DATE_RANGE="${3:-}"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 <query> [limit] [date_range]"
    echo "Example: $0 'CRISPR' 10 '2024-01-01/2024-12-31'"
    exit 1
fi

# bioRxiv API endpoint
# Using the details endpoint with date filtering
if [ -n "$DATE_RANGE" ]; then
    URL="https://api.biorxiv.org/details/biorxiv/${DATE_RANGE}/0"
else
    # Get recent papers (last 30 days)
    END_DATE=$(date +%Y-%m-%d)
    START_DATE=$(date -d '30 days ago' +%Y-%m-%d 2>/dev/null || date -v-30d +%Y-%m-%d)
    URL="https://api.biorxiv.org/details/biorxiv/${START_DATE}/${END_DATE}/0"
fi

# Fetch data
curl -sL "$URL" | python3 -m json.tool 2>/dev/null || curl -sL "$URL"
