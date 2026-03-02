# MMS Local Demo - Implementation Plan

## Objective
Get MMS running locally with a working demo that shows: trains loading, canvas rendering, and basic API functionality.

---

## Phase 1: Cleanup IMPLEMENTATION_PLAN.md

**Task:** Rewrite `ralph/IMPLEMENTATION_PLAN.md` removing all placeholder tasks and focusing on local-first development.

**New structure:**
```markdown
# MMS Implementation Plan - Local Demo

## COMPLETED
- [x] Core Database Schema (Drizzle ORM)
- [x] API Routes (30+ endpoints)
- [x] Frontend Components (React + deck.gl + BlueprintJS)
- [x] Domain Services (~41,300 lines)

## OUT OF SCOPE (Local Demo)
- k8s/ - Kubernetes deployment
- monitoring/ - Prometheus/Grafana
- mms-optimizer/ - C++ binary (TypeScript fallback exists)
- .github/ - CI/CD workflows
- src/workers/ - BullMQ workers (optional)
- src/services/maximo-*.ts - External integration
- src/file-watcher/ - CSV ingestion

## P0 - Infrastructure Setup
- [ ] MMS-LOCAL-001: Install PostgreSQL 17 + TimescaleDB
- [ ] MMS-LOCAL-002: Install and start Redis
- [ ] MMS-LOCAL-003: Create database and user
- [ ] MMS-LOCAL-004: Copy .env.example to .env

## P1 - Database Initialization
- [ ] MMS-LOCAL-005: Run `bun install`
- [ ] MMS-LOCAL-006: Run `bunx drizzle-kit push --force`
- [ ] MMS-LOCAL-007: Run manual migrations (0001-0004)
- [ ] MMS-LOCAL-008: Load seed data (seed_demo.sql)

## P2 - Verification
- [ ] MMS-LOCAL-009: Verify database (128 trains, extensions, hypertables)
- [ ] MMS-LOCAL-010: Verify API starts and /health returns OK
- [ ] MMS-LOCAL-011: Verify frontend loads with train data
- [ ] MMS-LOCAL-012: Verify canvas renders and view switching works

## P3 - Bug Fixes (As Discovered)
- [ ] MMS-LOCAL-013: Fix any database connection issues
- [ ] MMS-LOCAL-014: Fix any API-frontend integration issues
- [ ] MMS-LOCAL-015: Fix any canvas rendering issues
```

---

## Phase 2: Infrastructure Setup Commands

### Prerequisites Check
```bash
brew --version          # Homebrew installed
bun --version           # Bun runtime
```

### Install Dependencies
```bash
brew install postgresql@17 redis
brew tap timescale/tap
brew install timescale/tap/timescaledb

# Add PostgreSQL to PATH
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Configure TimescaleDB
timescaledb-tune --quiet --yes
```

### Start Services
```bash
brew services start postgresql@17
brew services start redis
```

---

## Phase 3: Database Initialization

### Create Database
```bash
createdb mms
psql -d postgres -c "CREATE USER mms WITH PASSWORD 'mms_dev_password';"
psql -d postgres -c "ALTER DATABASE mms OWNER TO mms;"
psql -d postgres -c "ALTER USER mms CREATEDB SUPERUSER;"
```

### Initialize Schema
```bash
cd /Users/anotonio.silva/antonio/mms/system
cp .env.example .env
bun install
bunx drizzle-kit push --force
```

### Run Manual Migrations (ORDER MATTERS)
```bash
psql -U mms -d mms -f drizzle/manual/0001_extensions.sql
psql -U mms -d mms -f drizzle/manual/0002_timescaledb.sql
psql -U mms -d mms -f drizzle/manual/0003_functions.sql
psql -U mms -d mms -f drizzle/manual/0004_materialized_views.sql
```

### Load Demo Data
```bash
psql -U mms -d mms -f drizzle/manual/seed_demo.sql
```

### Revoke Superuser (Security)
```bash
psql -d postgres -c "ALTER USER mms WITH NOSUPERUSER;"
```

---

## Phase 4: Verification Steps

### Database Verification
```bash
# Train count (expect 128)
psql -U mms -d mms -c "SELECT COUNT(*) FROM trains;"

# Extensions loaded
psql -U mms -d mms -c "SELECT extname FROM pg_extension WHERE extname IN ('timescaledb', 'uuid-ossp');"

# Hypertable exists
psql -U mms -d mms -c "SELECT hypertable_name FROM timescaledb_information.hypertables;"
```

### API Verification
```bash
bun run dev:api
# Note the port from: API_SERVER_PORT=XXXX

curl http://localhost:XXXX/health
# Expect: {"status":"healthy",...}

curl http://localhost:XXXX/api/v1/fleets
# Expect: {"success":true,"data":[...3 fleets...]}
```

### Frontend Verification
```bash
bun run dev
# Open browser to URL shown by Vite

# Check:
# - UI loads without console errors
# - Sidebar shows 15+ trains
# - Canvas renders train blocks
# - View toggle (Strategic/Tactical/Operational) works
```

---

## Phase 5: Known Issues & Fixes

| Issue | Symptom | Fix |
|-------|---------|-----|
| TimescaleDB not found | Extension error in 0001 | Run `timescaledb_move.sh`, restart postgres |
| Permission denied | Can't create extension | Grant SUPERUSER temporarily |
| Hypertable fails | Error in 0002 | Ensure `drizzle push` ran first |
| Redis unhealthy | /ready shows redis down | Start redis: `brew services start redis` |
| API port conflict | Port already in use | Set `PORT=3001` in .env |

---

## Files to Modify

| File | Action |
|------|--------|
| `ralph/IMPLEMENTATION_PLAN.md` | **REWRITE** - Clean task list |
| `.env` | **CREATE** - Copy from .env.example |

## Files to Verify (Read-Only)

| File | Purpose |
|------|---------|
| `drizzle/manual/0001_extensions.sql` | PostgreSQL extensions |
| `drizzle/manual/0002_timescaledb.sql` | Hypertable setup |
| `drizzle/manual/seed_demo.sql` | Demo data (128 trains) |
| `src/lib/db/connection.ts` | Database connection |
| `src/api/server.ts` | API entry point |
| `vite.config.ts` | Frontend proxy config |

---

## Success Criteria

**Demo is ready when:**
1. `bun run dev` starts without errors
2. Browser shows MMS UI with trains in sidebar
3. Canvas renders train schedule blocks
4. View switching (Strategic/Tactical/Operational) works
5. Clicking a train shows details

---

## Estimated Effort

| Phase | Time |
|-------|------|
| Cleanup IMPLEMENTATION_PLAN.md | 15 min |
| Infrastructure setup | 30 min |
| Database initialization | 15 min |
| Verification & debugging | 1-2 hours |
| **Total** | **2-3 hours** |
