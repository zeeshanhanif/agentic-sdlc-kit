#!/usr/bin/env bash
# Shared by every behaviour case's fixture.sh. `claude plugin eval --scaffold`
# runs a case's fixture.sh inside a throwaway working directory, so these
# helpers build the fixture project *there* from the files beside this script.
#
#   use_base                     copy the todo-mini project (FEAT-001 verified)
#   add_feat_002 <tasks> [ui]    add docs/features/FEAT-002-complete-task with
#                                the named tasks variant (0of7 | 3of7 | 7of7 | wip)
#                                and, with "ui", its ui-design.md
#   overlay <dir>                copy a case-local overlay tree on top

set -euo pipefail
FIXTURES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

use_base() {
  cp -R "$FIXTURES/todo-mini/." .
}

add_feat_002() {
  local tasks="$1" ui="${2:-}"
  local dir="docs/features/FEAT-002-complete-task"
  mkdir -p "$dir"
  cp "$FIXTURES/feat-002/technical-design.md" "$dir/technical-design.md"
  cp "$FIXTURES/feat-002/tasks-$tasks.md" "$dir/tasks.md"
  if [ "$ui" = "ui" ]; then
    cp "$FIXTURES/feat-002/ui-design.md" "$dir/ui-design.md"
  fi
}

overlay() {
  cp -R "$1/." .
}
