#!/usr/bin/env bash

# Crontab script to update docker compose projects and purge Cloudflare cache
# Only updates projects where docker compose is already running
#
# Usage: ./compose_update.sh [--all]
#   --all    Update all compose projects without prompting
#   (no arg) Interactive mode: select from list

# Configuration file format (compose_update.conf):
#
#   # Configuration for docker compose update + Cloudflare cache purge
#
#   # Cloudflare credentials
#   CLOUDFLARE_API_TOKEN="your-api-token"
#   CLOUDFLARE_ZONE_ID="your-zone-id"
#
#   # Project mapping: directory -> domain
#   # Use __SKIP__ as the domain for projects that should not have cache purged
#   declare -A COMPOSE_PROJECTS
#   COMPOSE_PROJECTS=(
#       ["/path/to/project1"]="sub.example.com"
#       ["/path/to/project2"]="__SKIP__"
#   )

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_FILE="$SCRIPT_DIR/compose_update.conf"
START_TIME=$(date +%s)
ORIG_DIR="$(pwd)"

# Load configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# Derive COMPOSE_DIRS from COMPOSE_PROJECTS keys
COMPOSE_DIRS=("${!COMPOSE_PROJECTS[@]}")

# Parse arguments
SELECTED_DIRS=()
if [ "$1" = "--all" ]; then
    SELECTED_DIRS=("${COMPOSE_DIRS[@]}")
else
    # Interactive mode: show menu and prompt for selection
    echo "=========================================="
    echo "       SELECT COMPOSE PROJECTS"
    echo "=========================================="
    echo ""
    echo "Available compose directories:"
    echo ""

    # Display numbered list
    i=1
    for dir in "${COMPOSE_DIRS[@]}"; do
        # Check if running
        if [ -d "$dir" ]; then
            cd "$dir" 2>/dev/null || continue
            if docker compose ps --format json 2>/dev/null | grep -q '"State":"running"'; then
                status="✓ running"
            else
                status="⊘ stopped"
            fi
        else
            status="✗ not found"
        fi
        echo "  $i) $dir [$status]"
        ((i++))
    done

    echo ""
    echo "  0) Update ALL projects"
    echo ""
    echo "Enter numbers separated by spaces (e.g., '1 3 5'), or '0' for all:"
    read -r selection

    if [ -z "$selection" ]; then
        echo "No selection made. Exiting."
        exit 0
    fi

    # Parse selection
    for num in $selection; do
        if [ "$num" = "0" ]; then
            SELECTED_DIRS=("${COMPOSE_DIRS[@]}")
            break
        elif [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#COMPOSE_DIRS[@]}" ]; then
            SELECTED_DIRS+=("${COMPOSE_DIRS[$((num-1))]}")
        else
            echo "Invalid selection: $num"
        fi
    done

    if [ ${#SELECTED_DIRS[@]} -eq 0 ]; then
        echo "No valid selections. Exiting."
        exit 0
    fi

    echo ""
    echo "Selected ${#SELECTED_DIRS[@]} project(s) to update."
    echo ""
fi

# Track results
declare -A UP_STATUS       # dir -> "up" or "down"
declare -A UPDATE_STATUS   # dir -> "updated" or "no-change" or "failed"
declare -A CACHE_STATUS    # dir/host -> "purged" or "skipped" or "failed"
UPDATED_COUNT=0
NO_CHANGE_COUNT=0
FAILED_COUNT=0
UP_COUNT=0
DOWN_COUNT=0
PURGED_COUNT=0
CACHE_SKIPPED_COUNT=0
CACHE_FAILED_COUNT=0

# Get image digests for running containers in current compose project
get_current_digests() {
    local digests=""
    digests=$(docker compose ps --format json 2>/dev/null | while IFS= read -r line; do
        container_id=$(echo "$line" | grep -o '"ID":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$container_id" ]; then
            docker inspect --format '{{.Image}}' "$container_id" 2>/dev/null
        fi
    done | sort)
    echo "$digests"
}

# Purge Cloudflare cache for a specific host
purge_cloudflare_cache() {
    local host="$1"
    local response
    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/purge_cache" \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
        -H "Content-Type: application/json" \
        --data "{\"hosts\": [\"$host\"]}")

    if echo "$response" | grep -q '"success":true'; then
        echo "  ✓ Cloudflare cache purged for: $host"
        return 0
    else
        echo "  ✗ Failed to purge cache for $host: $response" >&2
        return 1
    fi
}

for dir in "${SELECTED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        cd "$dir" || { cd "$ORIG_DIR"; continue; }

        # Check if docker compose is running
        if docker compose ps --format json | grep -q '"State":"running"'; then
            UP_STATUS["$dir"]="up"
            ((UP_COUNT++))
            echo "Updating: $dir"

            # Get digests before update
            digests_before=$(get_current_digests)

            if docker compose up -d --pull always; then
                # Get digests after update
                digests_after=$(get_current_digests)

                if [ "$digests_before" != "$digests_after" ]; then
                    UPDATE_STATUS["$dir"]="updated"
                    ((UPDATED_COUNT++))
                    echo "  ✓ New version deployed"

                    # Purge Cloudflare cache for this host (only when actually updated)
                    host="${COMPOSE_PROJECTS[$dir]}"
                    if [ "$host" != "__SKIP__" ]; then
                        if purge_cloudflare_cache "$host"; then
                            CACHE_STATUS["$host"]="purged"
                            ((PURGED_COUNT++))
                        else
                            CACHE_STATUS["$host"]="failed"
                            ((CACHE_FAILED_COUNT++))
                        fi
                    else
                        CACHE_STATUS["$dir"]="skipped"
                        ((CACHE_SKIPPED_COUNT++))
                        echo "  ⊘ Cache purge skipped for this project"
                    fi
                else
                    UPDATE_STATUS["$dir"]="no-change"
                    ((NO_CHANGE_COUNT++))
                    echo "  ⊘ Already up-to-date"
                fi
            else
                UPDATE_STATUS["$dir"]="failed"
                ((FAILED_COUNT++))
                echo "  ✗ Docker compose update failed for: $dir" >&2
                CACHE_STATUS["$dir"]="skipped"
                ((CACHE_SKIPPED_COUNT++))
            fi
        else
            UP_STATUS["$dir"]="down"
            ((DOWN_COUNT++))
            UPDATE_STATUS["$dir"]="skipped"
            ((NO_CHANGE_COUNT++))
            echo "Skipping (not running): $dir"
            CACHE_STATUS["$dir"]="skipped"
            ((CACHE_SKIPPED_COUNT++))
        fi
    else
        UP_STATUS["$dir"]="down"
        ((DOWN_COUNT++))
        UPDATE_STATUS["$dir"]="skipped"
        ((NO_CHANGE_COUNT++))
        echo "Skipping (directory not found): $dir"
        CACHE_STATUS["$dir"]="skipped"
        ((CACHE_SKIPPED_COUNT++))
    fi
    cd "$ORIG_DIR"
done

# Print summary
echo ""
echo "=========================================="
echo "           UPDATE SUMMARY"
echo "=========================================="
echo ""

ELAPSED=$(( $(date +%s) - START_TIME ))
echo "--- RUN TIME ---"
echo "  Started:  $(date -d @$START_TIME '+%Y-%m-%d %H:%M:%S')"
echo "  Elapsed:  ${ELAPSED}s"
echo ""

echo "--- COMPOSE STATUS ---"
echo "  Up:   $UP_COUNT"
echo "  Down: $DOWN_COUNT"
echo ""

echo "--- UPDATE STATUS ---"
echo "  Updated:    $UPDATED_COUNT"
echo "  No-change:  $NO_CHANGE_COUNT"
echo "  Failed:     $FAILED_COUNT"
echo ""

if [ $UPDATED_COUNT -gt 0 ]; then
    echo "  ✓ Newly updated:"
    for dir in "${!UPDATE_STATUS[@]}"; do
        [ "${UPDATE_STATUS[$dir]}" = "updated" ] && echo "    - $dir"
    done
    echo ""
fi

if [ $FAILED_COUNT -gt 0 ]; then
    echo "  ✗ Failed to update:" >&2
    for dir in "${!UPDATE_STATUS[@]}"; do
        [ "${UPDATE_STATUS[$dir]}" = "failed" ] && echo "    - $dir" >&2
    done
    echo "" >&2
fi

echo "--- CACHE PURGE STATUS ---"
echo "  Purged:  $PURGED_COUNT"
echo "  Skipped: $CACHE_SKIPPED_COUNT"
echo "  Failed:  $CACHE_FAILED_COUNT"
echo ""

if [ $PURGED_COUNT -gt 0 ]; then
    echo "  ✓ Purged:"
    for host in "${!CACHE_STATUS[@]}"; do
        [ "${CACHE_STATUS[$host]}" = "purged" ] && echo "    - $host"
    done
    echo ""
fi

if [ $CACHE_SKIPPED_COUNT -gt 0 ]; then
    echo "  ⊘ Not purged (skipped/no mapping):"
    for host in "${!CACHE_STATUS[@]}"; do
        [ "${CACHE_STATUS[$host]}" = "skipped" ] && echo "    - $host"
    done
    echo ""
fi

if [ $CACHE_FAILED_COUNT -gt 0 ]; then
    echo "  ✗ Failed to purge:" >&2
    for host in "${!CACHE_STATUS[@]}"; do
        [ "${CACHE_STATUS[$host]}" = "failed" ] && echo "    - $host" >&2
    done
    echo "" >&2
fi

echo "=========================================="
echo "Total: ${#SELECTED_DIRS[@]} project(s) processed"
echo "=========================================="
