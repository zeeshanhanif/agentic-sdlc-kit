#!/usr/bin/env bash
# Builds this case's project state in the throwaway working directory.
. "$(dirname "$0")/../../_fixtures/lib.sh"
mkdir -p docs
cp "$FIXTURES/todo-mini/docs/srs.md" docs/srs.md
