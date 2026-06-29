# Pravidhi — Self-Progressive AI Ecosystem

**Pravidhi** is a non-stop, self-improving AI agent harness that:

- 🧠 **Self-progresses** — Every request trains the system (Karpathy-style training loop)
- ✅ **Accurate validation** — Multi-layer: schema + behavioral + regression + LLM-as-Judge
- ⏰ **Offline Cron** — Independent scheduler daemon that runs regardless of gateway state
- 🔌 **Universal registry** — Single discovery point for tools, MCP servers, skills, plugins, and hooks
- 🔀 **Smart provider routing** — Auto-select best model by price/throughput/latency with credential pooling
- 🛡️ **Resilient** — Automatic fallback chains + credential rotation + checkpoint rollback
- 🧩 **Hermes + Codex compatible** — Reuses existing skills, plugins, and MCP servers

## Quick Start

```bash
# Install
pip install -e ".[all]"

# Check status
pravidhi status

# Start interactive chat
pravidhi chat

# Start the offline cron daemon (independent process)
pravidhi cron start

# Run an auto-research cycle
pravidhi research cycle

# Validate a prompt through the multi-layer engine
pravidhi validate "Your prompt here"

# Start the OpenAI-compatible API server
pravidhi serve

# List discovered skills
pravidhi skills
```

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         PRAVIDHI ENGINE                                  │
│                                                                          │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────┐ │
│  │  Validation  │   │   Pipeline   │   │  Provider    │   │  Memory  │ │
│  │  Engine      │──▶│  (7 stages)  │──▶│  Router      │──▶│  System  │ │
│  │  (4 layers)  │   │              │   │  + Fallback  │   │  (3-tier)│ │
│  └──────────────┘   └──────────────┘   └──────────────┘   └──────────┘ │
│                                                                          │
│  ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────────┐ │
│  │  Offline Cron    │   │  Auto-Research   │   │  Unified Registry   │ │
│  │  Daemon          │   │  Training Loop   │   │  Tools/MCP/Plugins  │ │
│  │  (no gateway!)   │   │  (Karpathy-style)│   │  Skills/Hooks       │ │
│  └──────────────────┘   └──────────────────┘   └──────────────────────┘ │
│                                                                          │
│  ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────────┐ │
│  │  API Server      │   │  CLI Interface   │   │  Sandbox Executor   │ │
│  │  (OpenAI compat) │   │  (Click-based)   │   │  (Python/Node/Shell)│ │
│  └──────────────────┘   └──────────────────┘   └──────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

## Key Differentiators vs. Hermes Agent

| Capability | Hermes Agent | Pravidhi |
|-----------|-------------|----------|
| **Cron independence** | Requires Gateway process | **Standalone daemon**, runs independently |
| **Self-improvement** | None built-in | **Karpathy training loop** + skill generator |
| **Validation** | Tool-level schema | **Multi-layer** (schema + behavioral + regression + LLM judge) |
| **Experience DB** | No persistence | **Vector experience store**, queryable |
| **Unified registry** | Dispersed (tools/MCP/plugins separate) | **Single registry** for everything |
| **Cron no-agent mode** | Exists | **Extended** with native system commands + pipelines |
| **Offline execution** | Limited — needs Gateway | **Fully independent** — no daemon requirement |
| **Delivery resilience** | Platform-bound | **Pluggable** file/webhook/MQTT endpoints |

## Pipeline Stages

The self-progressive pipeline processes every request through 7 stages:

1. **Ingest** — Parse and classify user intent
2. **Validate Input** — Check clarity, completeness, safety (injection prevention)
3. **Decompose** — Break into sub-tasks when appropriate
4. **Route** — Select optimal provider + model by strategy
5. **Execute** — Run via tools/MCP/skills/plugins/LLM
6. **Validate Output** — Multi-layer validation (schema + behavioral + regression)
7. **Learn** — Record patterns, update experience DB, trigger auto-research

## Project Structure

```
pravidhi/
├── pravidhi.yaml          # Central configuration
├── pyproject.toml         # Python package
├── engine/                # Core engine
│   ├── config.py          # Multi-layer config loader
│   ├── registry.py        # Unified registry (tools/MCP/skills/plugins)
│   ├── pipeline.py        # 7-stage request lifecycle
│   ├── validator.py       # Multi-layer validation engine
│   ├── provider_router.py # Model routing + credential pools + fallback
│   └── sandbox.py         # Sandboxed code execution
├── cron/                  # Offline cron engine
│   └── scheduler.py       # Independent daemon, SQLite persistence
├── research/              # Auto-research engine
│   └── training_loop.py   # Karpathy-style training + skill generation
├── gateway/               # Transports
│   ├── api_server.py      # OpenAI-compatible FastAPI server
│   └── cli.py             # Click-based CLI
├── memory/                # Hierarchical memory
│   └── session.py         # Working + long-term memory manager
├── plugins/               # Plugin directory
└── tests/                 # Test suites
```

## Configuration

Config loads from (in priority order):
1. `pravidhi.yaml` (package defaults)
2. `~/.pravidhi/pravidhi.yaml` (user config)
3. `./pravidhi.yaml` (project-local)
4. Environment variables (`PRAVIDHI_*`)
5. CLI flags

## Auto-Research Cycle

The research engine runs autonomously (hourly via cron):

1. Analyze last 100 executions for mistake patterns
2. Generate fix-skills for recurring errors
3. Evaluate successful patterns for reuse
4. Calculate loss (= 1 - accuracy)
5. Check convergence (accuracy > 95%)
6. Store research report as experience
7. Generate Codex-compatible skill files

## Offline Cron

```bash
# Start the independent daemon (no gateway needed)
pravidhi cron start

# Add a job
pravidhi cron add daily-backup "0 2 * * *" --command "tar -czf backup.tar.gz /data"

# List jobs
pravidhi cron list

# Manage jobs
pravidhi cron pause <job-id>
pravidhi cron resume <job-id>
```

## License

MIT
