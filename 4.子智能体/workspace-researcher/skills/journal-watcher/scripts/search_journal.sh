#!/bin/bash
# Search papers from top scientific journals using Europe PMC

QUERY="$1"
JOURNAL="${2:-}"
LIMIT="${3:-20}"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 <query> [journal] [limit]"
    echo "Supported journals: nature, science, cell, pnas"
    echo "Example: $0 'machine learning' nature 10"
    exit 1
fi

# Build search query
SEARCH_QUERY=$(echo "$QUERY" | sed 's/ /%20/g')

# Use Europe PMC API (better for recent papers)
URL="https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=${SEARCH_QUERY}&format=json&pageSize=${LIMIT}&sortDate=y"

# Fetch data
curl -sL "$URL" | python3 -m json.tool 2>/dev/null || curl -sL "$URL"
