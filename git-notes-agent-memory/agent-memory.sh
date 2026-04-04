#!/usr/bin/env bash
# agent-memory.sh — Git notes-based agent memory helper
# Requires: bash, git
# Usage: ./agent-memory.sh <command> [options]

set -euo pipefail

NOTES_REF="refs/notes/agent-memory"
# Must NOT be nested under refs/notes/agent-memory — that ref is a leaf; Git cannot
# also create refs/notes/agent-memory/agents/... . Use a sibling namespace.
AGENTS_PREFIX="refs/notes/am-agents"

_notes_show() {
  git notes --ref="$NOTES_REF" show "$1" 2>/dev/null
}

_notes_show_ref() {
  local ref="$1"
  local sha="$2"
  git notes --ref="$ref" show "$sha" 2>/dev/null
}

_agent_ref() {
  printf '%s/%s' "$AGENTS_PREFIX" "$1"
}

_validate_agent_id() {
  local id="${1:-}"
  if [[ -z "$id" ]]; then
    echo "ERROR: agent id required" >&2
    exit 1
  fi
  if [[ ! "$id" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "ERROR: agent id must match [a-zA-Z0-9._-]+" >&2
    exit 1
  fi
}

_ensure_git() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "ERROR: not inside a git repository" >&2
    exit 1
  fi
}

_extract_fm_line() {
  # $1 = note text, $2 = key without colon (e.g. task_id)
  local key="$2"
  printf '%s' "$1" | awk -v k="$key" '
    /^---$/ { if (++dash == 2) exit; next }
    dash == 1 && $0 ~ "^"k":" {
      sub("^" k ":", "")
      gsub(/^ +| +$/, "", $0)
      gsub(/^"|"$/, "", $0)
      print
      exit
    }
  '
}

cmd_read() {
  _ensure_git
  local sha
  sha=$(git rev-parse HEAD)
  local note
  note=$(_notes_show "$sha" || true)

  if [[ -z "$note" ]]; then
    echo "# No agent memory found for HEAD ($sha)"
    echo "# Run './agent-memory.sh write' after your first commit to start tracking."
  else
    echo "$note"
  fi
}

cmd_write() {
  _ensure_git
  local sha
  sha=$(git rev-parse HEAD)

  echo "# Paste your YAML+Markdown note below, then press Ctrl-D (EOF)." >&2
  echo "# Format: YAML frontmatter (---) followed by Markdown body." >&2
  local content
  content=$(cat)

  if [[ -z "$content" ]]; then
    echo "ERROR: empty note — nothing written." >&2
    exit 1
  fi

  git notes --ref="$NOTES_REF" add -f -m "$content" "$sha"
  echo "OK: note written to $sha" >&2
}

cmd_write_message() {
  _ensure_git
  local sha
  sha=$(git rev-parse HEAD)
  local content="${1:-}"

  if [[ -z "$content" ]]; then
    echo "ERROR: empty note — nothing written." >&2
    exit 1
  fi

  git notes --ref="$NOTES_REF" add -f -m "$content" "$sha"
  echo "OK: note written to $sha" >&2
}

cmd_write_agent() {
  _ensure_git
  local id="${1:-}"
  _validate_agent_id "$id"
  shift || true

  echo "# Paste note for agent '$id' (YAML+Markdown), then Ctrl-D." >&2
  local content
  content=$(cat)

  if [[ -z "$content" ]]; then
    echo "ERROR: empty note — nothing written." >&2
    exit 1
  fi

  local sha ref
  sha=$(git rev-parse HEAD)
  ref="$(_agent_ref "$id")"

  git notes --ref="$ref" add -f -m "$content" "$sha"
  echo "OK: agent note written to $sha ref=$ref" >&2
}

cmd_write_agent_message() {
  _ensure_git
  local id="${1:-}"
  _validate_agent_id "$id"
  shift
  local content="${*:-}"

  if [[ -z "$content" ]]; then
    echo "ERROR: empty note — nothing written." >&2
    exit 1
  fi

  local sha ref
  sha=$(git rev-parse HEAD)
  ref="$(_agent_ref "$id")"

  git notes --ref="$ref" add -f -m "$content" "$sha"
  echo "OK: agent note written to $sha ref=$ref" >&2
}

cmd_read_agent() {
  _ensure_git
  local id="${1:-}"
  _validate_agent_id "$id"

  local sha ref note
  sha=$(git rev-parse HEAD)
  ref="$(_agent_ref "$id")"
  note=$(_notes_show_ref "$ref" "$sha" || true)

  if [[ -z "$note" ]]; then
    echo "# No agent memory for agent '$id' at HEAD ($sha)"
  else
    echo "$note"
  fi
}

cmd_list_agents() {
  _ensure_git
  local found=0
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    found=1
    local short="${ref#"$AGENTS_PREFIX"/}"
    printf '%s\n' "$short"
  done < <(git for-each-ref --format='%(refname)' "$AGENTS_PREFIX" 2>/dev/null || true)

  if [[ "$found" -eq 0 ]]; then
    echo "# No per-agent note refs under $AGENTS_PREFIX"
  fi
}

cmd_aggregate() {
  _ensure_git
  local sha
  sha=$(git rev-parse HEAD)
  echo "## aggregate @ HEAD $sha"
  echo ""

  local rows_file pair_file uniq_pairs
  rows_file="$(mktemp)"
  pair_file="$(mktemp)"
  uniq_pairs="$(mktemp)"
  trap 'rm -f "$rows_file" "$pair_file" "$uniq_pairs"' RETURN

  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    local aid="${ref#"$AGENTS_PREFIX"/}"
    local note
    note=$(_notes_show_ref "$ref" "$sha" || true)
    [[ -z "$note" ]] && continue

    local tid h
    tid="$(_extract_fm_line "$note" task_id)"
    h="$(_extract_fm_line "$note" hypothesis_hash)"

    printf '%s\t%s\t%s\n' "$aid" "${tid:-<missing>}" "${h:-<missing>}" >>"$rows_file"
  done < <(git for-each-ref --format='%(refname)' "$AGENTS_PREFIX" 2>/dev/null || true)

  if [[ ! -s "$rows_file" ]]; then
    echo "(no per-agent notes on this commit)"
    return 0
  fi

  echo "### per-agent (agent_id, task_id, hypothesis_hash)"
  column -t -s $'\t' "$rows_file" 2>/dev/null || cat "$rows_file"
  echo ""

  awk -F'\t' '$2 != "<missing>" && $3 != "<missing>" { print $2 "\t" $3 "\t" $1 }' "$rows_file" | sort -t $'\t' -k1,2 -k3,3 >"$pair_file" || true

  if [[ ! -s "$pair_file" ]]; then
    echo "### classification"
    echo "insufficient_data: need task_id and hypothesis_hash in frontmatter (see SCHEMA.md)"
    return 0
  fi

  echo "### classification (heuristic)"

  sort -u -t $'\t' -k1,2 -k3,3 "$pair_file" >"$uniq_pairs"

  # Same task_id + same hypothesis_hash with 2+ distinct agents -> wasteful_duplicate
  awk -F'\t' '{ k = $1 SUBSEP $2; c[k]++ }
    END {
      for (k in c) if (c[k] >= 2) {
        split(k, a, SUBSEP)
        print "wasteful_duplicate: task_id=" a[1] " hypothesis_hash=" a[2] " agents=" c[k]
      }
    }' "$uniq_pairs"

  # Same task_id, 2+ distinct agents AND 2+ distinct hypothesis_hash -> healthy_parallel
  local tid
  while IFS= read -r tid; do
    [[ -z "$tid" ]] && continue
    local nhash nagent
    nhash=$(awk -F'\t' -v t="$tid" '$1 == t { print $2 }' "$uniq_pairs" | sort -u | sed '/^$/d' | wc -l | tr -d '[:space:]')
    nagent=$(awk -F'\t' -v t="$tid" '$1 == t { print $3 }' "$uniq_pairs" | sort -u | sed '/^$/d' | wc -l | tr -d '[:space:]')
    if [[ "${nagent:-0}" -ge 2 && "${nhash:-0}" -ge 2 ]]; then
      echo "healthy_parallel: task_id=$tid distinct_hypothesis_hash=$nhash agents=$nagent"
    fi
  done < <(cut -f1 "$uniq_pairs" | sort -u)
}

cmd_show() {
  _ensure_git
  local sha="${1:-}"
  if [[ -z "$sha" ]]; then
    echo "Usage: ./agent-memory.sh show <commit-sha>" >&2
    exit 1
  fi
  local resolved
  resolved=$(git rev-parse "$sha" 2>/dev/null) || {
    echo "ERROR: cannot resolve '$sha'" >&2
    exit 1
  }
  local note
  note=$(_notes_show "$resolved" || true)
  if [[ -z "$note" ]]; then
    echo "# No agent memory for $sha"
  else
    echo "$note"
  fi
}

cmd_log() {
  _ensure_git
  local last=5
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --last) last="${2:-5}"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  git log --format="%H %s" -n "$last" | while IFS=' ' read -r sha subject rest; do
    local note
    note=$(_notes_show "$sha" || true)
    if [[ -n "$note" ]]; then
      echo "=== $sha — $subject ==="
      echo "$note"
      echo ""
    fi
  done
}

cmd_exists() {
  _ensure_git
  local sha
  sha=$(git rev-parse HEAD)
  _notes_show "$sha" >/dev/null 2>&1
}

cmd_init() {
  _ensure_git

  git config --local notes.displayRef "$NOTES_REF" 2>/dev/null || true

  echo "OK: agent-memory initialized."
  echo "   Canonical notes ref: $NOTES_REF"
  echo "   Per-agent prefix:    $AGENTS_PREFIX/<agent_id> (sibling of $NOTES_REF)"
  echo ""
  echo "To push canonical memory:"
  echo "   git push origin $NOTES_REF"
  echo "To push all per-agent notes:"
  echo "   git push origin 'refs/notes/am-agents/*'"
  echo "To fetch:"
  echo "   git fetch origin $NOTES_REF:$NOTES_REF"
  echo "   git fetch origin 'refs/notes/am-agents/*:refs/notes/am-agents/*'"
}

# ── dispatch ─────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
agent-memory.sh — Git notes-based agent memory

Commands:
  init                     Configure this repo for agent memory
  read                     Print current HEAD note (canonical ref)
  write                    Write canonical note for HEAD from stdin
  write-message <text>     Write canonical note for HEAD (argument)
  write-agent <id>         Write per-agent note for HEAD from stdin
  write-agent-message <id> <text>   Per-agent note (non-interactive)
  read-agent <id>          Print per-agent note for HEAD
  list-agents              List agent ids that have a notes ref
  aggregate                Classify overlap on HEAD (task_id / hypothesis_hash)
  show <sha>               Print canonical note for a commit
  log [--last N]           Recent commits with canonical notes
  exists                   Exit 0 if HEAD has canonical note

Workflow:
  Session start:  ./agent-memory.sh read
  After commit:   ./agent-memory.sh write  (or write-message)
  Parallel work:  ./agent-memory.sh write-agent <id> ; ./agent-memory.sh aggregate
EOF
}

COMMAND="${1:-}"
shift || true

case "$COMMAND" in
  init)                cmd_init ;;
  read)                cmd_read ;;
  write)               cmd_write ;;
  write-message)       cmd_write_message "$@" ;;
  write-agent)         cmd_write_agent "$@" ;;
  write-agent-message) cmd_write_agent_message "$@" ;;
  read-agent)          cmd_read_agent "$@" ;;
  list-agents)         cmd_list_agents ;;
  aggregate)           cmd_aggregate ;;
  show)                cmd_show "$@" ;;
  log)                 cmd_log "$@" ;;
  exists)              cmd_exists ;;
  help|--help|-h)      usage ;;
  "")                  usage; exit 1 ;;
  *)                   echo "ERROR: unknown command '$COMMAND'" >&2; usage >&2; exit 1 ;;
esac
