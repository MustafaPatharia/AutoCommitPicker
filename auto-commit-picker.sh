#!/bin/bash

# Function to handle errors with user-friendly messages
error_exit() {
    echo "Error: $1"
    exit 1
}

# Check for required arguments
if [ "$#" -lt 4 ]; then
    error_exit "Usage: $0 <target_branch> <source_branch> <tags> <start_commit>"
fi

# Arguments
TARGET_BRANCH="$1"
SOURCE_BRANCH="$2"
TAGS="$3"
START_COMMIT="$4"

# Convert comma-separated tags into an array
IFS=',' read -r -a TAG_ARRAY <<< "$TAGS"

# Generate a random ID for the temporary branch
ID_NUMBER=$((RANDOM % 90000 + 10000))
TEMP_BRANCH="${SOURCE_BRANCH}_temp_${ID_NUMBER}"

# Checkout and update the target branch
git checkout "$TARGET_BRANCH" || error_exit "Failed to checkout target branch $TARGET_BRANCH"
git pull origin "$TARGET_BRANCH" || error_exit "Failed to pull latest changes from $TARGET_BRANCH"

# Create a new temporary branch from the target branch
git checkout -b "$TEMP_BRANCH" || error_exit "Failed to create temporary branch $TEMP_BRANCH"

# Prepare to capture commits for all specified tags
COMMITS=()

echo "Processing tags: ${TAG_ARRAY[*]}"

# Loop through each tag to find matching commits after the specified start commit
for TAG in "${TAG_ARRAY[@]}"; do
    echo "Searching for commits with tag: $TAG"

    # Execute the command to get commit info in single-line format
    TAG_COMMITS=$(git log "$START_COMMIT".."$SOURCE_BRANCH" --grep="#$TAG\b" --format="%H %ct %an" --reverse) || error_exit "Error finding commits with tag #$TAG"

    if [ -n "$TAG_COMMITS" ]; then
        echo "Commits found for tag #$TAG:"

        while IFS= read -r line; do
            COMMITS+=("$line")
        done <<< "$TAG_COMMITS"
    else
        echo "No commits found for tag #$TAG."
    fi
done

temp_COMMITS=()

# Loop through each commit entry to filter out duplicates
for commit in "${COMMITS[@]}"; do
    # Check if the commit is already in the temp_COMMITS array
    if [[ ! " ${temp_COMMITS[*]} " =~ " ${commit} " ]]; then
        temp_COMMITS+=("$commit")  # Add it if it's not already there
    fi
done

# Assign unique commits back to the COMMITS array
COMMITS=("${temp_COMMITS[@]}")

# Check if any commits were found
if [ ${#COMMITS[@]} -eq 0 ]; then
    echo "No commits found for the specified tags after commit $START_COMMIT."
    git checkout "$SOURCE_BRANCH"
    git branch -D "$TEMP_BRANCH"
    exit 0
fi

# Cherry-pick commits one by one, handling conflicts if they arise
for LINE in "${COMMITS[@]}"; do
    read -r COMMIT_HASH COMMIT_TIMESTAMP COMMIT_AUTHOR <<< "$LINE"

    COMMIT_DATE=$(date -r "$COMMIT_TIMESTAMP" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -jf "%s" "$COMMIT_TIMESTAMP" "+%Y-%m-%d %H:%M:%S")

    echo "Cherry-picking commit: $COMMIT_HASH by $COMMIT_AUTHOR on $COMMIT_DATE"

    # Attempt to cherry-pick the commit
    if git cherry-pick "$COMMIT_HASH"; then
        echo "Successfully cherry-picked commit $COMMIT_HASH."
    else
        # Check for conflicts
        if git ls-files -u | grep -q .; then
            echo "Conflict detected in commit $COMMIT_HASH. Please resolve manually."
            echo "After resolving, press [Enter] to continue to the next commit or type 'exit' to abort."
            read -r input
            if [ "$input" == "exit" ]; then
                error_exit "Aborting cherry-pick process."
            fi
        else
            echo "Failed to cherry-pick commit $COMMIT_HASH for unknown reasons."
            break  # Exit the loop for unknown errors
        fi
    fi
done

# Notify user of completion
echo "All cherry-pick operations are complete. You can now push your changes."
git push origin "$TEMP_BRANCH" || error_exit "Failed to push changes to $TEMP_BRANCH"
