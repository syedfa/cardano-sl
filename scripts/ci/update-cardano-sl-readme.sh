#!/bin/bash
set -euo pipefail

echo "Cardano SL README.md updating"

readonly CARDANO_DOCS_REPO_NAME=cardanodocs.com
readonly CARDANO_SL_REPO_NAME=cardano-sl
readonly PATH_TO_CARDANO_DOCS_REPO="${HOME}"/"${CARDANO_DOCS_REPO_NAME}"
readonly PATH_TO_CARDANO_SL_REPO="${HOME}"/"${CARDANO_SL_REPO_NAME}"
readonly PATH_TO_NODE_SUBDIR="${PATH_TO_CARDANO_SL_REPO}"/lib/
readonly README=README.md
readonly PATH_TO_DOCS_CHAPTERS="${PATH_TO_CARDANO_DOCS_REPO}"/_docs/

# Clone repository with an ability to push into it.
cloneRepository () {
    # Env variable ${GITHUB_CARDANO_DOCS_ACCESS_2} already stored in Travis CI settings.
    # This token gives us an ability to push into repository.
    readonly REPO_NAME=$1
    readonly PATH_TO_REPO=$2
    echo "**** Cloning ${REPO_NAME} repository ****"
    rm -rf "${PATH_TO_REPO}"
    git clone --quiet --branch=master https://"${GITHUB_CARDANO_DOCS_ACCESS_2}"@github.com/input-output-hk/"${REPO_NAME}" "${PATH_TO_REPO}"
}

cloneRepository "${CARDANO_DOCS_REPO_NAME}" "${PATH_TO_CARDANO_DOCS_REPO}"
cloneRepository "${CARDANO_SL_REPO_NAME}"   "${PATH_TO_CARDANO_SL_REPO}"

echo "**** Building ${README} from documentation ****"

{ echo "<!-- THIS IS AUTOGENERATED FILE. DO NOT CHANGE IT MANUALLY! -->"
  echo ""
  echo "# Cardano SL";
  echo "";
  echo "[![Build Status](https://travis-ci.org/input-output-hk/cardano-sl.svg)](https://travis-ci.org/input-output-hk/cardano-sl)";
  echo "[![Windows build status](https://ci.appveyor.com/api/projects/status/github/input-output-hk/cardano-sl?branch=master&svg=true)](https://ci.appveyor.com/project/jagajaga/cardano-sl)";
  echo "[![Release](https://img.shields.io/github/release/input-output-hk/cardano-sl.svg)](https://github.com/input-output-hk/cardano-sl/releases)";
  echo "";
} >> "${README}"

readonly PART_COMMON=CARDANO_SL_README_
readonly PART_BEGIN="${PART_COMMON}"BEGIN_
readonly PART_END="${PART_COMMON}"END_
# Current version of the ${README} is building from 5 parts.
for i in {1..5}; do
    # Find current part of the ${README} using hidden comments, extract it and append to ${README}.
    find "${PATH_TO_DOCS_CHAPTERS}" -iname '*.md' -exec sed -n "/$PART_BEGIN$i/,/$PART_END$i/p" "{}" >> "${README}" \;
done

echo "**** Copy new ${README} in ${CARDANO_SL_REPO_NAME} ****"
mv -f "${README}" "${PATH_TO_NODE_SUBDIR}"

echo "**** Push all changes, if required ****"
cd "${PATH_TO_CARDANO_SL_REPO}"
git add .
if [ -n "$(git status --porcelain)" ]; then 
    echo "     There are changes in ${README}, push it...";
    git commit -a -m "Automatic ${README} rebuilding."
    git push -f origin master
else
    echo "     No changes in ${README}, skip.";
fi
