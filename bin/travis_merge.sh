#!/bin/bash -e

# Based on https://chrisdown.name/2015/09/27/auto-merging-successful-builds-from-travis-ci.html
# This script expects an environment variable set up in Travis called GITHUB_TOKEN containing
# a valid Github personal access token with repo access.

export GIT_COMMITTER_EMAIL='travis@travis'
export GIT_COMMITTER_NAME='Travis CI'
repo_name="mikepowell/hass-config-main"

# Since Travis does a partial checkout, we need to get the whole thing
repo_temp=$(mktemp -d)
git clone "https://github.com/$repo_name" "$repo_temp"

# shellcheck disable=SC2164
cd "$repo_temp"

printf 'Checking out production\n' >&2
git checkout production

printf 'Merging commit %s\n' "$TRAVIS_COMMIT" >&2
git merge --ff-only "$TRAVIS_COMMIT"

printf 'Pushing to production\n' >&2

push_uri="https://$GITHUB_TOKEN@github.com/$repo_name"

# Redirect to /dev/null to avoid secret leakage
git push "$push_uri" production >/dev/null 2>&1
