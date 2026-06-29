# Pravidhi — Self-Progressive AI Ecosystem

**Pravidhi** is a non-stop, self-improving AI agent harness that combines:

- 🧠 **Self-progressive learning** — Karpathy-style training loop that improves from every request
- ✅ **Multi-layer validation** — Schema + behavioral + regression + LLM-as-Judge
- ⏰ **Offline Cron** — Independent scheduler daemon (no gateway dependency)
- 🔀 **Smart provider routing** — Auto-select best model by price/throughput/latency
- 🛡️ **Cybersecurity Agent** — Merged VulnClaw engine + 817 MITRE-mapped skills
- 🔬 **Reverse Engineering** — Ghidra (PyGhidra), z3-solver, LLM-assisted decompilation
- 🌐 **9Router Agent** — Model-agnostic pentesting via OpenRouter
- 📊 **Web Control UI** — Full dashboard for managing the entire ecosystem
- 🧩 **Universal registry** — Single discovery point for tools, MCP, skills, plugins

---

## Quick Start

```bash
# Install (all features)
pip install -e ".[all]"

# Or via curl one-liner
bash -c "$(curl -fsSL https://raw.githubusercontent.com/yashas-13/pravidhi/main/scripts/install.sh)"

# Check status
pravidhi status

# Run diagnostics
pravidhi doctor
pravidhi doctor --fix   # Auto-repair all issues

# Start the web control UI
pravidhi serve --host 0.0.0.0 --port 8642
# Open http://localhost:8642 in your browser

# Start interactive chat
pravidhi chat

# Start offline cron daemon
pravidhi cron start
```

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                              PRAVIDHI ECOSYSTEM                                        │
│                                                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  ┌─────────────┐ │
│  │  Validation  │  │   Pipeline   │  │  Provider    │  │  Memory  │  │  Web Control│ │
│  │  Engine      │─▶│  (7 stages)  │─▶│  Router      │─▶│  System  │  │  UI         │ │
│  │  (4 layers)  │  │              │  │  + Fallback  │  │  (3-tier)│  │  Dashboard  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────┘  └─────────────┘ │
│                                                                                        │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │  Offline Cron    │  │  Auto-Research   │  │  Cyber Agent     │  │  Reverse Eng  │ │
│  │  Daemon          │  │  Training Loop   │  │  VulnClaw + 817  │  │  Ghidra + z3  │ │
│  │  (no gateway!)    │  │  (Karpathy-style)│  │  Skills + OODA   │  │  + LLM Decomp │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  └───────────────┘ │
│                                                                                        │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │  9Router Agent   │  │  API Server      │  │  CLI Interface   │  │  Unified      │ │
│  │  OpenRouter      │  │  (OpenAI compat) │  │  (Click-based)   │  │  Registry     │ │
│  │  Model-agnostic  │  │  + Control UI    │  │  + Subcommands   │  │  Tools/MCP/etc│ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  └───────────────┘ │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Features

### 1. Self-Progressive Pipeline

Every request flows through 7 stages:
1. **Ingest** — Parse and classify user intent
2. **Validate Input** — Check clarity, completeness, safety (injection prevention)
3. **Decompose** — Break into sub-tasks when appropriate
4. **Route** — Select optimal provider + model by strategy
5. **Execute** — Run via tools/MCP/skills/plugins/LLM
6. **Validate Output** — Multi-layer validation (schema + behavioral + regression)
7. **Learn** — Record patterns, update experience DB, trigger auto-research

### 2. Offline Cron Daemon

Runs as an independent process — no gateway required.

```bash
pravidhi cron start          # Start daemon
pravidhi cron add backup "0 2 * * *" --command "tar -czf backup.tar.gz /data"
pravidhi cron list           # List jobs
pravidhi cron pause <id>     # Pause a job
pravidhi cron resume <id>    # Resume a job
```

### 3. Cybersecurity Agent

Merged VulnClaw engine + 817 Anthropic Cybersecurity Skills (MITRE/NIST mapped).

```bash
pravidhi cyber pentest example.com --intent "full pentest"
pravidhi cyber scan example.com --command "nmap -sV"
pravidhi cyber skills "sql injection"    # Search 817 skills
pravidhi cyber mitre T1190               # Find skills by MITRE ID
pravidhi cyber report                    # Show latest report
```

### 4. Reverse Engineering

Binary analysis via Ghidra (PyGhidra), symbolic execution (z3), LLM decompilation.

```bash
pravidhi re analyze /path/to/binary --depth full
pravidhi re symbols /path/to/binary      # Symbolic constraint solving
pravidhi re decompile --code "assembly here" --arch x64
```

### 5. 9Router Agent

Model-agnostic pentesting through OpenRouter. Use any model (GPT-5, Claude, Gemini, etc.).

```bash
pravidhi router pentest example.com --model "anthropic/claude-sonnet-4.6"
pravidhi router scan example.com --command "nmap -sV"
pravidhi router models                   # List available models
```

### 6. Auto-Research Engine

Continuous learning from every execution.

```bash
pravidhi research cycle      # Run one research cycle
pravidhi research status     # Show training metrics
pravidhi research practice "prompt" --epochs 5  # Practice-perfect loop
```

### 7. Web Control UI

Full browser-based dashboard for managing everything.

```bash
pravidhi serve --host 0.0.0.0 --port 8642
# Open http://localhost:8642
```

**Dashboard features:**
- System overview with real-time stats
- Cron job management (create/pause/delete)
- Cybersecurity pentest runner
- Reverse engineering binary analysis
- Pipeline testing
- Provider configuration viewer
- Research engine controls
- Live system logs
- Doctor diagnostics & auto-fix

### 8. Provider Routing

Smart multi-provider routing with credential pooling and automatic fallback.

```bash
pravidhi providers                          # List configured providers
pravidhi chat --model gpt-5.4-mini --provider openai
pravidhi validate "prompt"                  # Test validation engine
```

### 9. Doctor Diagnostics

Full system health check with auto-repair.

```bash
pravidhi doctor              # Full diagnostics
pravidhi doctor --fix        # Auto-repair all issues
pravidhi doctor --deps       # Install missing dependencies
```

---

## Installation

### Linux / Termux

```bash
# Option 1: Curl one-liner (recommended)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/yashas-13/pravidhi/main/scripts/install.sh)"

# Option 2: From domain
curl -fsSL https://pravidhisolutions.in/install.sh | bash

# Option 3: Manual
git clone https://github.com/yashas-13/pravidhi.git
cd pravidhi
pip install -e ".[all]"
```

### Install Optional Dependencies

```bash
# For cybersecurity features
pip install -e ".[cyber]"

# For reverse engineering features
pip install -e ".[re]"

# For everything
pip install -e ".[all]"
```

### VPS Deployment

```bash
# Deploy to VPS
./scripts/deploy.sh root@your-server.com

# Or with password
SSHPASS='password' ./scripts/deploy.sh root@your-server.com

# Remote doctor
./scripts/deploy.sh --doctor

# Remote doctor --fix
./scripts/deploy.sh --fix

# Curl install on VPS
ssh root@your-server.com 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/yashas-13/pravidhi/main/scripts/install.sh)"'
```

---

## API Reference

### REST API (OpenAI-compatible)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/v1/models` | List models |
| POST | `/v1/chat/completions` | Chat completions |
| GET | `/api/status` | System status |
| GET | `/api/stats` | Real-time statistics |
| GET | `/api/logs?lines=50` | System logs |
| GET | `/api/cron/jobs` | List cron jobs |
| POST | `/api/cron/jobs` | Create cron job |
| DELETE | `/api/cron/jobs/{id}` | Delete cron job |
| POST | `/api/cron/jobs/{id}/toggle` | Pause/resume |
| POST | `/api/cyber/pentest` | Run pentest |
| POST | `/api/cyber/scan` | Run scan |
| GET | `/api/cyber/skills` | Search skills |
| POST | `/api/re/analyze` | Analyze binary |
| POST | `/api/pipeline/run` | Run pipeline |
| GET | `/api/providers` | List providers |
| GET | `/api/doctor` | Run diagnostics |
| POST | `/api/doctor/fix` | Auto-fix |
| POST | `/api/research/cycle` | Research cycle |
| GET | `/api/research/status` | Research status |

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `OPENROUTER_API_KEY` | OpenRouter API key for model routing | For LLM features |
| `OPENAI_API_KEY` | OpenAI API key | Optional |
| `ANTHROPIC_API_KEY` | Anthropic API key | Optional (RE) |
| `GEMINI_API_KEY` | Google Gemini API key | Optional |
| `ROUTER_MODEL` | Default model for router agent | Optional |

---

## Commands Reference

```
pravidhi [OPTIONS] COMMAND [ARGS]...

Options:
  --config, -c TEXT   Config file path
  --verbose, -v       Verbose output
  --version           Show version

Commands:
  chat                Interactive chat session
  cron                Offline cron daemon management
  research            Auto-research engine
  status              System status
  serve               Start API server + control UI
  validate            Validate a prompt
  skills              List discovered skills
  doctor              System diagnostics & repair
  providers           List configured providers
  cyber               Cybersecurity agent
  router              9Router agent (OpenRouter)
  re                  Reverse engineering tools
  design              Google Labs DESIGN.md tools
  dx                  Agent DX CLI Scale tools
  tdd                 TDD Red-Green-Refactor workflow
  contracts           Typed Service Contracts
  ink                 @json-render/ink terminal UI
```

---

## Project Structure

```
pravidhi/
├── pravidhi.yaml              # Central configuration
├── pyproject.toml             # Python package
├── scripts/
│   ├── install.sh             # Curl-based installer
│   └── deploy.sh              # VPS deployment script
├── engine/                    # Core engine
│   ├── config.py              # Multi-layer config loader
│   ├── registry.py            # Unified registry (tools/MCP/skills/plugins)
│   ├── pipeline.py            # 7-stage request lifecycle
│   ├── validator.py           # Multi-layer validation engine
│   ├── provider_router.py     # Model routing + credential pools + fallback
│   ├── sandbox.py             # Sandboxed code execution
│   ├── reverse_engineering.py # Ghidra, z3, LLM decompilation
│   └── google_labs_tools.py   # DESIGN.md, DX Scale, TDD, ink, contracts
├── cron/                      # Offline cron engine
│   └── scheduler.py           # Independent daemon, SQLite persistence
├── research/                  # Auto-research engine
│   └── training_loop.py       # Karpathy-style training + skill generation
├── gateway/                   # Transports
│   ├── cli.py                 # Click-based CLI (main entry)
│   ├── api_server.py          # OpenAI-compatible FastAPI server
│   ├── doctor.py              # System diagnostics & auto-repair
│   └── control_ui/            # Web dashboard
│       ├── dashboard.py       # FastAPI routes for control UI
│       └── static/            # Static assets
├── router_agent/              # 9Router agent (merged VulnClaw + skills)
│   └── core.py                # Model-agnostic pentesting via OpenRouter
├── cyber/                     # Cybersecurity agent
│   ├── agent/
│   │   └── core.py            # VulnClaw bridge + skill management
│   └── cli/
│       └── commands.py        # Cyber CLI commands
├── memory/                    # Hierarchical memory
│   └── session.py             # Working + long-term memory manager
├── plugins/                   # Plugin directory
├── skills/                    # Local skill files
│   ├── reverse-engineering/   # Reverse engineering skill
│   ├── agent-dx-cli-scale/
│   ├── ink/
│   ├── tdd/
│   └── typed-service-contracts/
└── tests/
    └── test_all.py            # Comprehensive test suite
```

---

## Technical Deep Dive

### Pipeline Stages

```
Ingest → Validate Input → Decompose → Route → Execute → Validate Output → Learn
```

Each stage is a pluggable handler. Pipeline context flows through all stages.

### Multi-Layer Validation

1. **Schema** — Pydantic validation of tool inputs/outputs
2. **Behavioral** — LLM-as-Judge behavioral assessment
3. **Regression** — Compare against known-good patterns database
4. **Test Suite** — Run recorded test cases against output

### Provider Routing Strategy

- **Sort by**: price, throughput, or latency
- **Credential pools**: round_robin, least_used, fill_first, random
- **Fallback**: cascading fallback chain with retry

### Cybersecurity Workflow

1. **Recon** — Target enumeration, OSINT, subdomain discovery
2. **Discovery** — Port scanning, service fingerprint, vulnerability scan
3. **Exploitation** — Automated exploit attempt with 817 skill augmentation
4. **Privilege Escalation** — Post-exploitation enumeration
5. **Persistence** — Backdoor analysis, persistence mechanism detection
6. **Reporting** — Structured report with CVSS scoring, MITRE mapping, remediation

### Reverse Engineering Pipeline

1. **Format Detection** — PE, ELF, Mach-O, firmware, .NET, Java class
2. **Information Extraction** — Entropy, strings, imports/exports, hashes
3. **Deep Analysis** — Ghidra (PyGhidra) function extraction, call graph
4. **Symbolic Execution** — z3-solver constraint solving, vulnerability detection
5. **LLM Decompilation** — Claude/GPT-4o function explanation, pseudocode generation

---

## License

MIT
