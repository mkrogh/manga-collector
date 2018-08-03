#!/usr/bin/env bash
# Simplified implementation using only curl

usage() { echo "Usage: $0 [-n] [-c <start_chapter>] [-l <last_chapter>] <mangareader_url>" 1>&2; exit 1; }

START_CHAPTER=1
DRY_RUN=false
while getopts ":c:l:n" opt; do
  case "${opt}" in
    c) START_CHAPTER=${OPTARG} ;;
    l) LAST_CHAPTER=${OPTARG} ;;
    n) DRY_RUN=true ;;
    \?) usage ;;
    esac
done
shift $((OPTIND-1))
LAST_CHAPTER=${LAST_CHAPTER:-$START_CHAPTER}

if [ "$#" -ne 1 ]; then
  usage
fi

BASE_URL="https://www.mangareader.net"
MANGA_URL=$1
# When encountering id="chapterlist" set x=1, when encountering class="clear" set x=0
# if x==1 and line contains href print the line
chapter_list=$(curl -s "$MANGA_URL" | awk 'x==1 && /href/ {print $0} /id="chapterlist"/ {x=1} /class="clear"/ {x=0}')

# Sanity check chapter output
if [ -z "$chapter_list" ]; then
  echo "Failed to get chapter list for $MANGA_URL"
  exit 2
fi

titleize() {
  echo "$1" | sed -e 's/<[^>]*>//g' -e 's/[^A-Za-z0-9():][^A-Za-z0-9():]*/_/g' -e 's/_*:_*/-/' -e's/[-_]$//'
}

chapter_url() {
  echo "$1" | awk -F '"' -v base_url="$BASE_URL" '{print base_url$2}'
}

for i in $(seq $START_CHAPTER $LAST_CHAPTER); do
  chapter_line=$(echo "$chapter_list" | awk "NR==$i")
  chapter_title=$(titleize "$chapter_line")
  chapter_link=$(chapter_url "$chapter_line")

  chapter_page=$(curl -s "$chapter_link")
  page1=$(echo "$chapter_page" | awk -F "src=" '/id="imgholder"/ {print $2}' | awk -F '"' '{print $2}')
  page1_nbr=$(echo "$page1" | sed 's/\....$//' | grep -o "[0-9]*$")
  page_list=$(echo "$chapter_page" | awk 'x==1 && /option/ {print $0} /id="pageMenu"/ {x=1} /<\/div>/ {x=0}')
  total_pages=$(echo "$page_list" | wc -l)
  page1_ext=".${page1##*.}"


  if [ -f "${chapter_title}.cbz" ]; then
    echo "Skipping chapter $i, ${chapter_title}.cbz already exist"
    continue
  fi

  # make chapter dir if missing
  if [ ! -d "$chapter_title" ]; then
    if $DRY_RUN; then
      echo "Creating folder $chapter_title"
    else
      mkdir "$chapter_title"
    fi
  fi

  for j in $(seq 0 $total_pages); do
    printf "Downloading: ${chapter_title} [$((j+1))/$((1+total_pages))] \r"
    next_page=$(echo $page1 | sed "s/${page1_nbr}\./$((page1_nbr + j))./")
    printf -v file '%s/%03d%s' "$chapter_title" "$((j+1))" "$page1_ext"
    if [ -f "$file" ]; then
      # File exist skip to next
      continue
    fi

    if $DRY_RUN; then
      echo "Downloading: $next_page to $file"
    else
      if ! curl -s -o "$file" "$next_page"; then
        # failed to dl from guessed url.
        [ -f "$file" ] && rm "$file"
        page_path=$(echo "$page_list" | awk -F '"' -v j="$j" 'NR==j {print $2}')
        current_page=$(curl -s "$BASE_URL$page_path" | awk -F "src=" '/id="imgholder"/ {print $2}' | awk -F '"' '{print $2}')
     
        if ! curl -s -o "$file" "$current_page"; then
          echo "Failed to download Chapter $i, Page $j"
          exit 3
        fi
      fi
    fi
  done

  if $DRY_RUN; then
    echo "Creating zip archive $chapter_title.cbz"
  else
    zip -q -j "${chapter_title}.cbz" "${chapter_title}"/* 
    [ -d "$chapter_title" ] && rm -r "${chapter_title}"
  fi
  echo "Completed: ${chapter_title}.cbz Total pages: $((1 + total_pages))"
done

