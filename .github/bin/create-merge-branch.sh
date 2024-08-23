#!/usr/bin/env bash

#####
# This script creates a branch that merges the latest release
#####

set -ex

# Only allow running on main
CURRENT_BRANCH="$(git branch --show-current)"
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "[ERROR] This script can only be run on the main branch" >&2
  exit 1
fi

if [ -n "$(git status --short)" ]; then
  echo "[ERROR] This script cannot run with uncommitted changes" >&2
  exit 1
fi

UPSTREAM_REPO="${UPSTREAM_REPO:-"stackhpc/ansible-slurm-appliance"}"
echo "[INFO] Using upstream repo - $UPSTREAM_REPO"

# Fetch the tag for the latest release from the upstream repository
RELEASE_TAG="$(curl -fsSL "https://api.github.com/repos/${UPSTREAM_REPO}/releases/latest" | jq -r '.tag_name')"
echo "[INFO] Found latest release tag - $RELEASE_TAG"

# Add the repository as an upstream
echo "[INFO] Adding upstream remote..."
git remote add upstream "https://github.com/${UPSTREAM_REPO}.git"
git remote show upstream

echo "[INFO] Fetching remote tags..."
git remote update

# Use a branch that is named for the release
BRANCH_NAME="upgrade/$RELEASE_TAG"

# Check if the branch already exists on the origin
# If it does, there is nothing more to do as the branch can be rebased from the MR
if git show-branch "remotes/origin/$BRANCH_NAME" >/dev/null 2>&1; then
  echo "[INFO] Merge branch already created for $RELEASE_TAG"
  exit
fi

echo "[INFO] Merging release tag - $RELEASE_TAG"
git merge --strategy recursive -X theirs --no-commit $RELEASE_TAG

# Check if the merge resulted in any changes being staged
if [ -n "$(git status --short)" ]; then
  echo "[INFO] Merge resulted in the following changes"
  git status

  # NOTE(scott): The GitHub create-pull-request action does
  # the commiting for us, so we only need to make branches
  # and commits if running outside of GitHub actions.
  if [ ! $GITHUB_ACTIONS ]; then
    echo "[INFO] Checking out temporary branch '$BRANCH_NAME'..."
    git checkout -b "$BRANCH_NAME"

    echo "[INFO] Committing changes"
    git commit -m "Upgrade ansible-slurm-applaince to $RELEASE_TAG"

    echo "[INFO] Pushing changes to origin"
    git push --set-upstream origin "$BRANCH_NAME"

    # Go back to the main branch at the end
    echo "[INFO] Reverting back to main"
    git checkout main

    echo "[INFO] Removing temporary branch"
    git branch -d "$BRANCH_NAME"
  fi

  # Write a file containing the branch name and tag
  # for automatic PR or MR creation that follows
  echo "BRANCH_NAME=\"$BRANCH_NAME\"" > .mergeenv
  echo "RELEASE_TAG=\"$RELEASE_TAG\"" >> .mergeenv
else
  echo "[INFO] Merge resulted in no changes"
fi