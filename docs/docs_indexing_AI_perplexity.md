Here’s the full content of `docs_indexng_AI.md` so you can copy it into your repo:

***

# Docs and history indexing for AI agents

## Objectives

- Index two main corpora:
  - Project `docs/` tree (AI instructions, standards, specs, routing docs).
  - Large history corpus (epoch / chapter folders, ~1000+ `.md` files).
- Let AI agents **find the right file or small chunk** for a given task or historical event.
- Minimize manual routing (`claude.md` maintenance) and **limit context** to only what is needed per task.

***

## Top recommended stack

### 1. Primary search engine: gnosis-mcp (preferred)

- **What it is**: Local-first documentation search MCP server.
  - Indexes local docs (Markdown and other text-like formats) into SQLite with FTS5, with optional embeddings + pgvector for hybrid search. [pypi](https://pypi.org/project/gnosis-mcp/0.6.3/)
  - Exposes tools like `search_docs` and `get_doc` over MCP for Claude Code, Cursor, etc. [cursor](https://cursor.directory/plugins/mcp-gnosis-mcp)
  - Uses heading-aware chunking and tuned defaults based on BEIR-style evaluation to return small, high-signal excerpts. [gnosismcp](https://gnosismcp.com)
- **Why it fits**:
  - Designed specifically for **developer / documentation projects**, which maps well onto your `docs/` tree and history notes. [gnosismcp](https://gnosismcp.com)
  - Returns **ranked excerpts** instead of whole files, which keeps context small and focused. [gnosismcp](https://gnosismcp.com)
  - Runs fully locally with SQLite by default (good for N100), with optional upgrade to hybrid semantic search when needed. [pypi](https://pypi.org/project/gnosis-mcp/0.6.3/)
- **How to use it** (conceptually):
  - Ingest both corpora:
    - `gnosis-mcp ingest ./docs`
    - `gnosis-mcp ingest ./history` (or equivalent root for history notes). [pypi](https://pypi.org/project/gnosis-mcp/0.6.3/)
  - In Claude / agent prompts, steer queries:
    - Project work: “Use gnosis to search only within `docs/` when you need instructions or standards for this repo.”
    - History work: “Use gnosis to search only within `history/` when answering history questions.”

**Fit score for your use case**: **93/100**.

***

### 2. Alternative search engines

These are strong alternatives or complements to gnosis-mcp.

#### DuckDB Hybrid Doc Search (MCP)

- **What it is**: MCP server that indexes Markdown/docs into DuckDB and offers **hybrid BM25 + vector search + cross-encoder re-ranking**. [github](https://github.com/upamune/duckdb-hybrid-doc-search)
- **Pros**:
  - Very strong hybrid retrieval for proper names, dates, and phrases (important for historical events and feature IDs). [mcpnest](https://mcpnest.io/servers/duckdb-hybrid-doc-search)
  - Docker-ready, straightforward configuration.
- **Cons**:
  - Slightly more infra (DuckDB file, Python) and config than gnosis-mcp’s default `pip install && ingest && serve` flow.

**Fit score**: **92/100**.

#### QMD – Query Markdown (MCP)

- **What it is**: Node-based CLI + MCP server for **BM25 + vector + LLM re-rank** search over local Markdown collections. [mcp-gallery](https://www.mcp-gallery.jp/mcp/github/ehc-io/qmd)
- **Pros**:
  - Mature in the MCP ecosystem, designed as “local Markdown search for AI agents”. [lobehub](https://lobehub.com/mcp/ehc-io-qmd)
  - Collections map nicely to `docs/` vs `history/`.
- **Cons**:
  - Node/JS dependency; embedding stack and resource profile differ from the Python-first stack you already use. [knightli](https://www.knightli.com/en/2026/05/01/qmd-markdown-search-for-ai-agents/)

**Fit score**: **85/100**.

#### Markdown-RAG MCP (Milvus-based)

- **What it is**: Markdown RAG MCP servers that index local Markdown into Milvus/Milvus Lite, with heading-aware chunking and semantic search. [conare](https://conare.ai/marketplace/mcp/markdown-rag)
- **Pros**:
  - Good semantic RAG; incremental indexing.
- **Cons**:
  - Requires Milvus and more ops overhead; semantic-only by default, so exact-date/name questions may be weaker than hybrid FTS+vector.

**Fit score**: **86/100** (good, but heavier than needed for your scale).

***

## Instruction and routing layer for `docs/`

### MCPInstructionServer (or equivalent Instruction MCP)

- **What it is**: TypeScript MCP server that recursively scans Markdown instruction files, extracts titles and summaries, and exposes them as structured “instructions” via tools like `list_instructions` and `get_instruction`. [getdrio](https://www.getdrio.com/mcp/mcpinstructionserver-martinschlott)
- **Why it fits your `docs/` tree**:
  - Your `docs/specs/`, `docs/env/`, `docs/product/`, and `docs/standards/` already follow an instruction/spec pattern (quick starts, test strategy, ai-agent guides, etc.).
  - Instruction MCP can **replace most of the manual routing in `claude.md`**: the agent can list instructions, read summaries, and then fetch only the few that are relevant to the task. [playbooks](https://playbooks.com/mcp/rach/instruction)
- **Usage pattern**:
  - Point Instruction MCP at `docs/`.
  - In `claude.md`, replace large manual index sections with guidance like: “Use the Instruction MCP server to discover relevant specs and standards; only load the specific instructions you need into context.”

**Fit score for routing project docs**: **82/100** for docs, lower for history (not designed for free-form notes).

### markymark (Markdown LSP + MCP)

- **What it is**: Markdown-focused LSP + MCP server; provides navigation, link analysis, diagnostics, and refactor support across Markdown trees. [mcp.aibase](https://mcp.aibase.com/server/1639703162946593499)
- **Why it’s useful**:
  - Helps enforce structural consistency and link hygiene in your `docs/` tree without manual maintenance.
  - Lets agents understand and follow links within `claude.md`, specs, and standards, reinforcing your “top router” design without hand-curating every path. [mcp.aibase](https://mcp.aibase.com/server/1639703162946593499)

**Fit score**: **79/100** (strong structural/maintenance complement to gnosis-mcp + Instruction MCP).

***

## Other relevant tools in this space

### basic-memory

- **What it is**: Local-first AI memory system that stores an entity/observation/relationship graph as Markdown and indexes it via SQLite, with an MCP server for read/write memory operations. [basicmachines](https://basicmachines.co/blog/what-is-basic-memory/)
- **Strengths**:
  - Excellent for **conversational, writable memory** — e.g., AI notes about how history quizzes went, debugging logs, decisions.
- **Limitations** for this project:
  - Less suited as the primary search over a large static corpus (history corpus + stable docs) than gnosis-mcp or DuckDB Hybrid. [jimmysong](https://jimmysong.io/ai/basic-memory/)

**Fit score**: **80/100** — good secondary layer for “AI’s own notes”, not the main search engine.

### dotMD

- **What it is**: Local hybrid search MCP server for Markdown combining semantic vectors, BM25, and a small internal knowledge graph (entities/relations). [reddit](https://www.reddit.com/r/aiagents/comments/1qsdrq3/dotmd_local_hybrid_search_for_markdown_files/)
- **Strengths**:
  - Fully local, no external APIs; graph-flavored view over notes.
- **Limitations**:
  - Smaller ecosystem and documentation than gnosis-mcp / QMD / DuckDB. [reddit](https://www.reddit.com/r/opencodeCLI/comments/1qsds8f/dotmd_local_hybrid_search_for_markdown_files/)

**Fit score**: **82/100** — strong alternative if you prioritize “graph feel” and full locality over ecosystem maturity.

### IWE – Interwoven Wiki Engine

- **What it is**: Markdown-native knowledge graph + LSP/CLI that turns notes into a hierarchical graph and supports fast structural operations and navigation. [dev](https://dev.to/gimalay/markdown-knowledge-graph-for-humans-and-agents-43c4)
- **Strengths**:
  - Ideal if you want to explicitly model historical periods, themes, and cross-links as a graph, shared between humans and agents.
- **Limitations**:
  - Not a retrieval engine by itself; best paired with gnosis-mcp / DuckDB for initial search, then used for graph traversal. [github](https://github.com/iwe-org/iwe)

**Fit score**: **76/100** — great second-phase enhancement once search is solved.

### LlamaIndex + vector DBs (Chroma, Qdrant, Weaviate)

- **What it is**: Python framework for building custom RAG pipelines; Markdown-aware loaders and splitters; can be wrapped into an MCP server using their MCP integration module. [developers.llamaindex](https://developers.llamaindex.ai/python/framework/module_guides/mcp/)
- **Strengths**:
  - Maximum control (custom metadata, multi-step routing, epoch tags, difficulty labels, etc.).
- **Limitations**:
  - More engineering and maintenance work than using ready-made MCP servers like gnosis-mcp or DuckDB Hybrid. [blog.csdn](https://blog.csdn.net/The_Thieves/article/details/147023157)

**Fit score**: **78/100** — useful if you want a custom research agent later; not needed to solve your immediate problem.

### Plain Markdown + simple search / index.md

- **Pattern**: Maintain an `index.md` (or a few) as the human/AI entrypoint and rely on filesystem + keyword search for most retrieval; escalate to RAG only when absolutely necessary. [voxos](https://voxos.ai/blog/how-to-give-ai-coding-agents-long-term-m/index.html)
- **Strengths**:
  - Low infra, transparent, Git-native; aligns with “plain text is the best long-term memory” philosophy. [dev](https://dev.to/imaginex/ai-agent-memory-management-when-markdown-files-are-all-you-need-5ekk)
- **Limitations**:
  - At your scale (1000+ history files + complex `docs/`), manual routing becomes a burden, which is what you want to avoid.

**Fit score**: **70/100** — good baseline philosophy, but insufficient by itself for your goals.

***

## Final recommendations

### A. Minimal, high-leverage setup (recommended)

1. **Use gnosis-mcp as your primary search engine** over both `docs/` and history corpus.
   - Start with the default SQLite+FTS configuration (no embeddings) to keep it light. [pypi](https://pypi.org/project/gnosis-mcp/0.6.3/)
   - Add path-based filters in prompts (e.g., `docs/` vs `history/`), so agents don’t mix project instructions with historical content.
2. **Add MCPInstructionServer for routing within `docs/`.**
   - Let it auto-discover and summarize instruction/spec files like `AI_AGENT_QUICK_START.md`, `test-strategy.md`, `ai-agent-development-guide.md`. [github](https://github.com/MartinSchlott/MCPInstructionServer)
   - Simplify `claude.md` so it mainly explains how to use the Instruction MCP and gnosis-mcp instead of hardcoding a long index.
3. **Optionally add markymark** for structural hygiene and link-aware navigation.
   - Use it to keep internal links consistent and allow agents to follow references across specs, standards, and product docs. [mcp.aibase](https://mcp.aibase.com/server/1639703162946593499)

This stack gives you:

- Fast, accurate search for both history and project docs.
- Minimal manual routing (Instruction MCP + structure-aware search instead of big hand-written routers).
- Small, precise context windows (excerpt-based retrieval + per-task instruction selection).

### B. Alternative if you prefer DuckDB/py-first stack

If you’d rather standardize on DuckDB and Python:

1. Replace gnosis-mcp with **DuckDB Hybrid Doc Search MCP** for both corpora. [github](https://github.com/upamune/duckdb-hybrid-doc-search)
2. Keep **MCPInstructionServer** and optional **markymark** as above. [getdrio](https://www.getdrio.com/mcp/mcpinstructionserver-martinschlott)

You lose some of gnosis’ documentation-focused UX, but gain a very strong hybrid search engine built entirely on Python + DuckDB. [mcpnest](https://mcpnest.io/servers/duckdb-hybrid-doc-search)

### C. Long-term enhancements

- Introduce **basic-memory** as a separate “AI working memory” for reflections and decisions, not as the primary corpus index. [github](https://github.com/basicmachines-co/basic-memory)
- Layer **IWE** or **dotMD** if you later want richer graph semantics for history (e.g., traversing related events, visualizing links) beyond what gnosis / DuckDB give you. [reddit](https://www.reddit.com/r/aiagents/comments/1qsdrq3/dotmd_local_hybrid_search_for_markdown_files/)
- Consider a custom **LlamaIndex + MCP** service only if you need specialized routing (difficulty levels, multi-language support, or multi-agent pipelines) that off-the-shelf MCP servers cannot cover cleanly. [dev](https://dev.to/sophyia/how-to-build-a-rag-solution-with-llama-index-chromadb-and-ollama-20lb)