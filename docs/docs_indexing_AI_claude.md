# Docs Indexing for AI Agents — Research Summary & Recommendations

> **Context:** Evaluating solutions to automatically index markdown-based project knowledge bases
> so AI agents can retrieve only the relevant files for a given task — without manually
> maintained routing files. Target deployment: Ubuntu mini-PC (Intel N100, 16 GB RAM),
> local-only, no cloud dependencies, simplicity prioritised over perfect fit.

---

## Problem Statement

A project `docs/` folder with 44 markdown files across 13 directories (specs, env, product,
standards, test-plans, etc.) is used as a knowledge base by AI coding agents. The current
approach relies on a manually maintained `claude.md` router file that agents read first, then
follow to relevant subdocs. This breaks when files move or are added, and requires ongoing
human maintenance.

**Goals:**
- Eliminate manually maintained routing/index files
- Limit context loaded by the agent to what is relevant to the current task
- Run fully locally on a low-power Ubuntu server
- Keep the solution simple enough that it maintains itself

---

## How Agent-Facing MD Indexing Works

All solutions in this space follow one of three retrieval patterns:

| Pattern | How it works | Best for |
|---|---|---|
| **Full-text (BM25/FTS5)** | Keyword matching ranked by term frequency | Exact names, dates, error codes, config values |
| **Semantic (vector)** | Embedding similarity — finds meaning, not words | Conceptual queries, paraphrased searches |
| **Hybrid** | Combines both with Reciprocal Rank Fusion (RRF) | Most real-world agent queries |

The best solutions expose results via **MCP (Model Context Protocol)**, which lets Claude Code,
Claude Desktop, Cursor, and other agents call a `search_docs` tool mid-conversation instead of
loading entire files into context.

---

## Solutions Evaluated

### Tier 1 — Recommended (local, simple, MCP-native)

#### 1. gnosis-mcp ⭐ Top pick
- **Repo:** https://github.com/nicholasglazer/gnosis-mcp
- **Stack:** Python, SQLite FTS5, optional local ONNX embeddings (~23 MB, no API key)
- **Score: 91/100**
- Designed specifically as a project docs knowledge base for AI coding agents
- Auto-categorises documents by parent directory name — your `specs/`, `env/`, `product/`
  folders become queryable categories with zero configuration
- Smart chunking by H2 headings, never splits inside code blocks or tables
- Extracts YAML frontmatter (title, category, audience, tags) if present
- Incremental re-indexing via content hashing — only changed files are re-processed
- Watch mode auto-re-ingests on file changes (`gnosis-mcp serve --watch ./docs/`)
- 6 MCP tools exposed: `search_docs`, `get_doc`, `get_related`, `list_docs`, `upsert_doc`, `delete_doc`
- Ships with Agent Skills presets (`/gnosis:search`, `/gnosis:setup`)
- SQLite default needs no server; upgrades to PostgreSQL + pgvector if scale demands it

```bash
pip install gnosis-mcp[embeddings]
gnosis-mcp ingest ./docs/ --embed
gnosis-mcp serve --watch ./docs/
```

```json
{ "mcpServers": { "docs": { "command": "gnosis-mcp", "args": ["serve", "--watch", "./docs/"] } } }
```

---

#### 2. Basic Memory
- **Repo:** https://github.com/basicmachines-co/basic-memory
- **Stack:** Python, SQLite, FastEmbed embeddings
- **Score: 88/100**
- Reads existing `.md` files into a local SQLite knowledge graph
- Hybrid FTS5 + semantic search; traverses wiki-style links between notes via `memory://` URLs
- Two-way read/write — agent can annotate notes, not just read them
- Works with Obsidian vaults without restructuring files
- Best choice if your docs cross-reference each other (e.g. `specs/` linking to `standards/`)
- Single `uvx` install command

```bash
uvx basic-memory mcp
```

---

#### 3. MCP-Markdown-RAG
- **Repo:** https://github.com/Zackriya-Solutions/MCP-Markdown-RAG
- **Stack:** Python, sentence-transformers (~50 MB)
- **Score: 83/100**
- Simplest semantic option — single Python file, minimal config
- Recursive directory indexing covers nested folder structures in one command
- Force-reindex flag for manual refresh; natural language queries
- Good fallback if gnosis-mcp proves too complex to troubleshoot

---

### Tier 2 — Good options (slightly more setup)

#### 4. dotMD
- **Repo:** https://github.com/inventivepotter/dotmd
- **Stack:** Python, LanceDB + SQLite + graph DB
- **Score: 80/100**
- Highest search quality: semantic + BM25 + knowledge graph + CrossEncoder reranking, all embedded
- GLiNER NER entity extraction automatically builds a relationship graph across docs
- Caveat: MCP server and API server cannot run simultaneously (single graph DB connection)
- Newer project — monitor for stability before using in production

#### 5. QMD (tobi/qmd)
- **Repo:** https://github.com/tobi/qmd
- **Stack:** Node.js, BM25 + GGUF local LLM reranking
- **Score: 79/100**
- Named collections map naturally to your folder groups (`env/`, `specs/`, `product/`)
- Local LLM reranking requires no API key; may be slow on N100 for large result sets
- Actively developed (updated within days of research)

#### 6. markymark
- **Repo:** https://github.com/nicholasmckinney/markymark
- **Stack:** Rust binary, LSP + optional ONNX
- **Score: 68/100**
- Lightweight Rust binary — ideal for a low-power server
- Structural navigation: heading trees, broken link detection, cross-doc link traversal
- Pre-release; semantic search is an optional add-on, not the default
- Best used as a complement to gnosis-mcp (structure) rather than a replacement

---

### Tier 3 — Overkill or wrong fit for N100

| Solution | Score | Reason to skip |
|---|---|---|
| markdown-rag-mcp (Milvus) | 42 | Requires Docker + Milvus; heavy RAM usage |
| LlamaIndex + ChromaDB | 48 | "Build your own" — contradicts simplicity goal |
| vault-mcp | 61 | FastAPI server adds operational complexity; watch mode in gnosis-mcp covers same need |
| Obsidian + Smart Connections | 44 | Requires Obsidian GUI running on a headless server |

---

### Not recommended — wrong category

| Solution | Score | Reason |
|---|---|---|
| Serena (LSP) | 18 | Code symbol analysis — no prose/heading search for markdown |
| GitNexus | 15 | Code knowledge graph — markdown support not implemented |

---

## Final Recommendation

### Primary: gnosis-mcp + Basic Memory

Run both in tandem — they are complementary, not competing:

| Tool | Role |
|---|---|
| **gnosis-mcp** | Fast keyword + semantic search over all docs; directory-aware; auto-maintained |
| **Basic Memory** | Graph traversal for cross-referenced docs; agent can write notes back |

**gnosis-mcp** replaces the manually maintained `claude.md` router entirely. The agent calls
`search_docs("database seeding")` and retrieves `development/database-seeding.md` without
loading any routing file. File moves and additions are picked up automatically on the next
watch cycle.

**Basic Memory** adds value if your feature specs link to standards docs, or if you want the
agent to persist notes about decisions made during a session.

### Setup on Ubuntu N100 server

```bash
# Install
pip install gnosis-mcp[embeddings]
uvx basic-memory mcp  # separate terminal or systemd service

# Index and start watching
gnosis-mcp ingest ./docs/ --embed
gnosis-mcp serve --watch ./docs/ --host 0.0.0.0 --port 8765
```

**systemd service** (recommended for a mini-PC server):

```ini
# /etc/systemd/system/gnosis-mcp.service
[Unit]
Description=gnosis-mcp docs indexing server
After=network.target

[Service]
ExecStart=/usr/local/bin/gnosis-mcp serve --watch /path/to/docs/
Restart=on-failure
User=youruser

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now gnosis-mcp
```

### Claude Code / Desktop config

```json
{
  "mcpServers": {
    "docs": {
      "command": "gnosis-mcp",
      "args": ["serve", "--watch", "/absolute/path/to/docs/"]
    },
    "memory": {
      "command": "uvx",
      "args": ["basic-memory", "mcp"]
    }
  }
}
```

---

## Resource Requirements (N100 estimate)

| Component | RAM | CPU at idle | Notes |
|---|---|---|---|
| gnosis-mcp (SQLite mode) | ~80 MB | negligible | No embedding model loaded |
| gnosis-mcp (+ ONNX embeddings) | ~200 MB | low | 23 MB model, SIMD on N100 |
| Basic Memory | ~100 MB | negligible | SQLite only |
| **Total** | **~300 MB** | **< 5%** | Well within 16 GB headroom |

---

## What This Solves

| Problem | Before | After |
|---|---|---|
| Routing to relevant files | Manual `claude.md` router, updated by hand | Auto-categorised by directory; agent searches directly |
| New file added | Must update router manually | Picked up on next watch cycle, zero action needed |
| Agent loads too much context | Loads router + follows to files | Agent calls `search_docs`, gets only relevant chunks |
| Cross-doc navigation | Manual links or agent guesses | Graph traversal via Basic Memory `memory://` URLs |
| Deployment complexity | N/A | Single Python process + SQLite file; systemd service |

---

*Research conducted May 2026. Solutions verified against GitHub repos and MCP registries.
Scores reflect fit for: markdown project docs KB · local Ubuntu N100 deployment · simplicity to maintain.*
