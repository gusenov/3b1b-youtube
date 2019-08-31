#!/usr/bin/env bash

readonly SILENT="--silent"

readonly YOUR_API_KEY=""
readonly YouTube_channel_ID="UCYO_jab_esuFRV4b17AJtAw"

function PrintUploads() {
  local part="brandingSettings,contentDetails,contentOwnerDetails,id,invideoPromotion,localizations,snippet,statistics,status,topicDetails"
  local request="https://www.googleapis.com/youtube/v3/channels"

  curl $SILENT \
       --data "id=$YouTube_channel_ID" \
       --data "part=$part" \
       --data "key=$YOUR_API_KEY" \
       --get "$request" | \
  jq --raw-output '.items[0].contentDetails.relatedPlaylists.uploads'
}

function SaveAllItems() {
  local uploads=$(PrintUploads)

  local part="contentDetails,id,snippet,status"
  local request="https://www.googleapis.com/youtube/v3/playlistItems"

  local allItems="[]"
  echo "$allItems" > allItems.json

  local pageToken=""
  while true; do
    local response=$(
      curl $SILENT \
           --data "playlistId=$uploads" \
           --data "part=$part" \
           --data "maxResults=50" \
           --data "key=$YOUR_API_KEY" \
           --data "$pageToken" \
           --get "$request"
    )

    local items=$(echo "$response" | jq --raw-output '.items')
    echo "$items" > items.json
    allItems=$(jq -s '.[0] + .[1]' allItems.json items.json)
    echo "$allItems" > allItems.json

    local nextPageToken=$(echo "$response" | jq --raw-output 'select(.nextPageToken) | .nextPageToken')
    if [ -z "$nextPageToken" ]; then
      break
    else
      pageToken="pageToken=$nextPageToken"
    fi
  done

  [ -f "items.json" ] && rm "items.json"
}

SaveAllItems
