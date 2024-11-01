# Cherry-Picking Commits Based on Tags 🍒

## Overview
This bash script automates the process of cherry-picking commits from a source branch to a target branch based on specified tags. It simplifies the workflow of integrating specific changes without merging entire branches, allowing for more controlled updates.

## Features
- **Error Handling**: User-friendly error messages and safe exit on failure.
- **Dynamic Branch Creation**: Automatically creates a temporary branch to apply cherry-picked commits.
- **Duplicate Removal**: Filters out duplicate commits based on specified tags.
- **Manual Conflict Resolution**: Alerts users when conflicts occur during cherry-picking, allowing for manual resolution.

## Usage
To run the script, use the following syntax:

```bash
./auto_commit_picker.sh <target_branch> <source_branch> <tags> <start_commit>
