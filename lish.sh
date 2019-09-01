#!/usr/bin/env bash

function PrintMarkdownList() {
  local items=$(cat $1)
  local len=$(echo "$items" | jq 'length')

  for (( i=len-1; i>=0; i-- )); do
    item=$(echo "$items" | jq ".[$i]")
    snippet=$(echo "$item" | jq ".snippet")
    title=$(echo "$snippet" | jq --raw-output ".title")
    resourceId=$(echo "$snippet" | jq --raw-output ".resourceId")
    videoId=$(echo "$resourceId" | jq --raw-output ".videoId")
    echo "- [$title](https://www.youtube.com/watch?v=$videoId)"
  done
}

PrintMarkdownList "allItems.json" > list.md
