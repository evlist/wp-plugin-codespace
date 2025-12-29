#!/usr/bin/env bash
set -euo pipefail

log() { printf "[merge-env] %s\n" "$*"; }
die() { printf "[merge-env:ERROR] %s\n" "$*" >&2; exit 1; }

LOCALENV=${CODESPACE_VSCODE_FOLDER}/.env
DEVCONTAINER=${CODESPACE_VSCODE_FOLDER}/.devcontainer
DEFAULTENV=${DEVCONTAINER}/.env
TMP=${DEVCONTAINER}/tmp
MERGEDENV=${TMP}/.env.merged

mkdir -p $TMP
rm -f $MERGEDENV

for FILE in $DEFAULTENV $LOCALENV
do
    log "Copying $FILE (if exists)"
    echo "Copied from $FILE:" >> $MERGEDENV
    cat $FILE >> $MERGEDENV 2>/dev/null || true
    echo >> $MERGEDENV
done
