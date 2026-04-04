# git-notes-agent-memory

Agent memory on **Git notes**: canonical ref `refs/notes/agent-memory`, optional per-agent refs `refs/notes/am-agents/<id>`, and `aggregate` for overlap hints.

| File | Role |
|------|------|
| [SKILL.md](./SKILL.md) | When to use, two modes, push/fetch hints |
| [SCHEMA.md](./SCHEMA.md) | YAML frontmatter, Phase 3 optional fields |
| [agent-memory.sh](./agent-memory.sh) | `init`, `read`, `write`, `write-agent`, `aggregate`, … |

```bash
cp agent-memory.sh /path/to/your/repo/
chmod +x agent-memory.sh
./agent-memory.sh init
```

Reproducible experiments: **`agent-memory-lab`** (Phase 2–3 docs).
