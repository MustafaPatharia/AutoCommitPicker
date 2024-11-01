# Auto Cherry-Picking Commits Based on Tags 🍒

## Overview
This Bash script automates the cherry-picking of commits from a source branch to a target branch based on specified tags. It streamlines the process of integrating specific changes, allowing for a more controlled and efficient update without merging entire branches.

## Features
- **Error Handling**: Provides user-friendly error messages and exits safely on failure.
- **Dynamic Branch Creation**: Automatically creates a temporary branch for cherry-picking commits.
- **Duplicate Removal**: Efficiently filters out duplicate commits based on specified tags.
- **Manual Conflict Resolution**: Notifies users of conflicts during cherry-picking and facilitates manual resolution.

## Usage
To execute the script, use the following syntax:

```bash
./auto_commit_picker.sh <target_branch> <source_branch> <tags> <start_commit>
