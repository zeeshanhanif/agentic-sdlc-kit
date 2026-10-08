#!/usr/bin/env bash
# Static checks for this repository. The skills are instruction content, so
# "correct" here means: valid per the Agent Skills spec, internally consistent,
# and documented the way the README says. CI runs this on every push and pull
# request; run it locally before committing:
#
#   bash scripts/validate.sh            # everything
#   SKIP_MERMAID=1 bash scripts/validate.sh   # skip the Chromium download
#
# Each check prints one line per item. Any ERROR fails the run (exit 1).
# A tool that is missing locally makes its check "skip", never fail — CI
# installs uv, node and the claude CLI so nothing is skipped there.

set -uo pipefail
cd "$(dirname "$0")/.."

ERRORS=0
WARNINGS=0
ok()      { printf '  ok     %s\n' "$*"; }
skip()    { printf '  skip   %s\n' "$*"; }
warn()    { printf '  WARN   %s\n' "$*"; WARNINGS=$((WARNINGS + 1)); }
err()     { printf '  ERROR  %s\n' "$*"; ERRORS=$((ERRORS + 1)); }
section() { printf '\n== %s\n' "$*"; }

SKILLS=$(find skills -mindepth 1 -maxdepth 1 -type d | sed 's#skills/##' | sort)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
section "1. Agent Skills spec — agentskills validate (name, required keys, description ≤ 1024)"
if command -v agentskills >/dev/null 2>&1; then
  AS="agentskills"
elif command -v uvx >/dev/null 2>&1; then
  AS="uvx --from skills-ref agentskills"
else
  AS=""
fi
if [ -z "$AS" ]; then
  skip "no 'agentskills' or 'uvx' on PATH (pip install skills-ref, or install uv)"
else
  for s in $SKILLS; do
    if out=$($AS validate "skills/$s" 2>&1); then
      ok "$s"
    else
      err "$s: $(printf '%s' "$out" | grep -v '^Validation failed' | tr -s ' \n' ' ')"
    fi
  done
fi

# ---------------------------------------------------------------------------
section "2. Frontmatter — exactly two keys (name, description); name equals the directory"
for s in $SKILLS; do
  f="skills/$s/SKILL.md"
  if [ "$(head -1 "$f")" != "---" ]; then
    err "$s: SKILL.md does not start with a frontmatter block"
    continue
  fi
  keys=$(awk 'NR>1 && /^---/ {exit} NR>1 && /^[A-Za-z_-]+:/ {sub(/:.*/, ""); print}' "$f" | sort | tr '\n' ' ')
  if [ "$keys" != "description name " ]; then
    err "$s: frontmatter keys are [${keys% }] — expected exactly name + description (CLAUDE.md §2)"
  fi
  n=$(awk '/^name:/ {print $2; exit}' "$f")
  if [ "$n" != "$s" ]; then
    err "$s: frontmatter name '$n' does not match the directory name"
  else
    ok "$s"
  fi
done

# ---------------------------------------------------------------------------
section "3. Description length — warn above 1000 chars (spec cap is 1024; the trigger phrases sit at the end)"
# Exact count via the reference parser when available (YAML folding rules are
# subtle); otherwise an approximation from folding the block by hand.
for s in $SKILLS; do
  approx=""
  if [ -n "$AS" ] && command -v python3 >/dev/null 2>&1; then
    len=$($AS read-properties "skills/$s" 2>/dev/null \
      | python3 -c 'import json,sys; print(len(json.load(sys.stdin)["description"]))' 2>/dev/null)
  fi
  if [ -z "${len:-}" ]; then
    approx="≈ "
    len=$(awk '
      NR>1 && /^---/ {exit}
      /^description:/ {d=1; s=$0; sub(/^description:[ \t]*>?-?[ \t]*/, "", s); next}
      d && /^[A-Za-z_-]+:/ {d=0}
      d { line=$0; sub(/^[ \t]+/, "", line); s = (s == "" ? line : s " " line) }
      END { sub(/[ \t]+$/, "", s); print length(s) }
    ' "skills/$s/SKILL.md")
  fi
  if [ "$len" -gt 1024 ]; then
    err "$s: description ${approx}${len} chars (cap 1024)"
  elif [ "$len" -gt 1000 ]; then
    warn "$s: description ${approx}${len} chars — under 25 chars of headroom before the 1024 cap"
  else
    ok "$s (${approx}${len} chars)"
  fi
  len=""
done

# ---------------------------------------------------------------------------
section "4. References — every cited references/*.md exists; every reference file is cited somewhere in its skill"
for s in $SKILLS; do
  f="skills/$s/SKILL.md"
  for ref in $(grep -oE 'references/[a-z0-9-]+\.md' "$f" | sort -u); do
    [ -f "skills/$s/$ref" ] || err "$s: SKILL.md cites $ref but the file does not exist"
  done
  if [ -d "skills/$s/references" ]; then
    for path in skills/"$s"/references/*.md; do
      base=$(basename "$path")
      if ! grep -rlF "$base" "skills/$s" --exclude="$base" >/dev/null 2>&1; then
        err "$s: references/$base is never mentioned by SKILL.md or another reference (orphan)"
      fi
    done
  fi
  ok "$s"
done

# ---------------------------------------------------------------------------
section "5. README 'What's inside' trees match the files on disk"
awk '
  /^### What.s inside/ { want = 1; next }
  want && /^```text/   { intree = 1; want = 0; next }
  intree && /^```/     { intree = 0; next }
  intree {
    line = $0
    sub(/#.*/, "", line)
    gsub(/│|├|└|─/, "", line)
    gsub(/^[ \t]+|[ \t]+$/, "", line)
    if (line == "") next
    if (line ~ /^skills\//) { skill = line; sub(/\/$/, "", skill); dir = skill; next }
    if (line ~ /\/$/)       { dir = skill "/" line; sub(/\/$/, "", dir); next }
    print dir "/" line
  }
' README.md | sort > "$TMP/readme-tree.txt"
find skills -name '*.md' | sort > "$TMP/disk-tree.txt"
missing=$(comm -13 "$TMP/readme-tree.txt" "$TMP/disk-tree.txt")
extra=$(comm -23 "$TMP/readme-tree.txt" "$TMP/disk-tree.txt")
for p in $missing; do err "on disk but not in any README tree: $p"; done
for p in $extra;   do err "in a README tree but not on disk: $p"; done
[ -z "$missing$extra" ] && ok "$(wc -l < "$TMP/disk-tree.txt" | tr -d ' ') files, twelve trees agree with skills/"

# ---------------------------------------------------------------------------
section "6. Bare-name rule — skills refer to each other by bare name, never a slash form (CLAUDE.md §2)"
alt=$(printf '%s\n' $SKILLS | paste -sd'|' -)
hits=$(grep -rnE "(^|[^A-Za-z0-9/.>\`-])/($alt)([^a-z-]|$)" skills/ | grep -v 'agentic-sdlc-kit:' || true)
if [ -n "$hits" ]; then
  printf '%s\n' "$hits" | while IFS= read -r h; do err "slash-form skill reference: $h"; done
else
  ok "no slash-form references in skills/"
fi

# ---------------------------------------------------------------------------
section "7. Mermaid — every \`\`\`mermaid block in skills/ and README.md parses"
if [ "${SKIP_MERMAID:-}" = "1" ]; then
  skip "SKIP_MERMAID=1"
elif ! command -v npx >/dev/null 2>&1; then
  skip "npx not on PATH (needs node; mermaid-cli downloads Chromium on first use)"
else
  mkdir -p "$TMP/mmd"
  # Extract each block to <n>.mmd; mmd/index.txt maps n -> file:line.
  { find skills -name '*.md' | sort; echo README.md; } | while IFS= read -r f; do
    awk -v file="$f" -v out="$TMP/mmd" '
      BEGIN { while ((getline l < (out "/index.txt")) > 0) n++; close(out "/index.txt") }
      /^```mermaid/ { n++; blk = out "/" n ".mmd"; print n "\t" file ":" FNR >> (out "/index.txt"); open = 1; next }
      open && /^```/ { open = 0; close(blk); next }
      open { print > blk }
    ' "$f"
  done
  printf '{"args":["--no-sandbox","--disable-setuid-sandbox"]}\n' > "$TMP/puppeteer.json"
  count=0
  while IFS=$'\t' read -r n label; do
    blk="$TMP/mmd/$n.mmd"
    count=$((count + 1))
    if out=$(npx -y -p @mermaid-js/mermaid-cli mmdc -q -i "$blk" -o "$TMP/out.svg" -p "$TMP/puppeteer.json" 2>&1); then
      ok "$label"
    else
      err "$label: $(printf '%s' "$out" | grep -iE 'error|parse|expecting' | head -3 | tr -s ' \n' ' ')"
    fi
  done < "$TMP/mmd/index.txt"
  [ "$count" -gt 0 ] || warn "no mermaid blocks found — extraction is probably broken"
fi

# ---------------------------------------------------------------------------
section "8. Plugin manifests — valid, version only in plugin.json, no 'skills' field (CLAUDE.md §2)"
for m in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  if command -v claude >/dev/null 2>&1; then
    if out=$(claude plugin validate "$m" 2>&1) && ! printf '%s' "$out" | grep -q 'Found [0-9]* error'; then
      ok "$m validates"
    else
      err "$m: $(printf '%s' "$out" | grep -E '❯|error' | head -3 | tr -s ' \n' ' ')"
    fi
  else
    skip "$m: claude CLI not on PATH (npm i -g @anthropic-ai/claude-code)"
  fi
  grep -qE '^[[:space:]]*"skills"[[:space:]]*:' "$m" && err "$m declares a 'skills' field — skills/ is auto-discovered; the field must stay absent"
done
grep -qE '^[[:space:]]*"version"[[:space:]]*:' .claude-plugin/marketplace.json \
  && err "marketplace.json sets 'version' — plugin.json owns the version and would silently win"
grep -qE '^[[:space:]]*"version"[[:space:]]*:' .claude-plugin/plugin.json \
  || err "plugin.json has no 'version' — the release rule needs it"
ok "manifest field rules"

# ---------------------------------------------------------------------------
printf '\n== Result: %d error(s), %d warning(s)\n' "$ERRORS" "$WARNINGS"
[ "$ERRORS" -eq 0 ]
