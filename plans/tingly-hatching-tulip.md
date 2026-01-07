# F013: Storage Architecture - Plan

## Requirements

1. **ZERO JSON/TXT files** - Everything goes to DB
2. **DB is SSOT** - Single Source of Truth
3. **No need to be human-readable** - Can be optimized format
4. **Can be multiple files** - Locally merged by DB as needed
5. **Must NOT corrupt on git merge** - Unlike Photoshop files that break IN git
6. **Must be scalable** - Support large projects
7. **Graph-capable** - Creative connection of concepts (can be separate DB)
8. **Flexible location** - .harness/ or project root

---

## Problem to Solve

Today: `progress.txt` and `features.json` are read entirely each session → consumes tokens/context before starting work.

Solution: Database that allows efficient queries (read only what's needed).

---

## Open Questions

1. **SQLite with git** - Works well? Merge conflicts corrupt data?
2. **GraphLite** - Available on crates.io? File format?
3. **Multi-file DBs** - Which embedded DBs support sharded/multi-file storage?

---

## Next Step

Research DB options that meet requirements. Present options with pros/cons.
