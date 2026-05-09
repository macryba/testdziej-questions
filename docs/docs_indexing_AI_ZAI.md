# Documentation Indexing Research

**Created:** 2026-05-09
**Purpose:** Research summary for indexing markdown files (quiz files + docs) on N100/16GB Ubuntu server
**Status:** Active recommendations

---

## Executive Summary

After researching 15+ solutions for indexing markdown files to serve two purposes:

1. **History quiz files** (241 files in `history-data/`)
2. **Documentation folder** (44 files in `docs/` with 13 directories)

**Top Recommendation:** **gnosis-mcp** (9.0/10)
- Zero-config setup
- 5-10× token reduction
- Semantic search with local ONNX embeddings
- Perfect for N100/16GB hardware

**Alternative:** basic-memory (8.5/10)
- Knowledge graph features
- More mature project
- Requires more configuration

---

## Requirements

### Primary Goals
- ✅ Auto-discovery/indexing (no manual routing)
- ✅ Context-aware loading (minimal info for task)
- ✅ Dual-purpose: quiz files + documentation
- ✅ Runs on Ubuntu server (N100 + 16GB RAM)
- ✅ Values simplicity over perfect fit

### Hardware Constraints
- **CPU:** Intel N100 (4-core, burst up to 3.4GHz)
- **RAM:** 16GB
- **OS:** Ubuntu Server
- **Priority:** Lightweight, low maintenance

---

## Solution Comparison Table

| Solution | Description | Research Score | My Score | Hardware Fit | Setup | Token Efficiency | Recommendation |
|----------|-------------|----------------|----------|--------------|-------|------------------|----------------|
| **gnosis-mcp** | Zero-config MCP server for documentation search with SQLite/PostgreSQL, semantic embeddings, local ONNX (no API key), indexes docs + git history | N/A | **9.0/10** | ✅ Perfect | ⭐ Very Easy | ⭐⭐⭐⭐⭐ Best (5-10× reduction) | **🥇 TOP CHOICE** |
| **basic-memory** | Local-first knowledge graph with SQLite indexing, semantic vector search (v0.19.0), wiki-link traversal, bi-directional AI/human editing | 88/100 | **8.5/10** | ✅ Perfect | ⭐⭐⭐ Medium | ⭐⭐⭐ Good | **🥈 HIGH CHOICE** |
| **Simple Index File** | Single index.md with file listings, zero dependencies | N/A | **9.0/10** | ✅ Perfect | ⭐ Very Easy | ⭐⭐ Moderate | **🥉 FOR STARTING** |
| **MCP-Markdown-RAG** | Purpose-built semantic search for .md files with recursive subdirectory indexing, Milvus vector DB | 85/100 | **8.0/10** | ✅ Good | ⭐⭐ Simple | ⭐⭐⭐ Good | **✅ GOOD CHOICE** |
| **QMD** | BM25 + vector + LLM rerank hybrid search, containerized, 95% token reduction, requires OpenRouter API key | 81/100 | **7.0/10** | ⚠️ Needs API | ⭐⭐ Simple | ⭐⭐⭐⭐ Excellent | **⚠️ CONDITIONAL** |
| **vault-mcp** | RAG over standard .md vaults with live file-sync, quality-scored chunking, REST + MCP | 82/100 | **7.0/10** | ✅ Good | ⭐⭐ Simple | ⭐⭐⭐ Good | **✅ GOOD CHOICE** |
| **mcp-local-rag** | Semantic + keyword-boost search with LanceDB (no server process), includes Agent Skills | 79/100 | **7.5/10** | ✅ Perfect | ⭐⭐ Simple | ⭐⭐⭐ Good | **✅ GOOD CHOICE** |
| **dotMD** | Local hybrid search (semantic + BM25 + knowledge graph), cross-encoder rerank, zero API cost | N/A | **8.0/10** | ✅ Perfect | ⭐⭐⭐ Medium | ⭐⭐⭐⭐ Excellent | **✅ GOOD CHOICE** |
| **markymark** | MCP-native Markdown LSP with navigation, refactoring, structured data parsing | N/A | **6.0/10** | ✅ Good | ⭐⭐ Simple | ⭐⭐ Moderate | **⚠️ FOR CODE ONLY** |
| **IWE** | Markdown knowledge graph + LSP/CLI for organizing and traversing notes | N/A | **6.5/10** | ✅ Good | ⭐⭐⭐⭐ Complex | ⭐⭐⭐ Good | **❌ NOT RECOMMENDED** |
| **DuckDB Hybrid** | BM25 full-text + vector search with CrossEncoder re-ranking, Docker-ready | 80/100 | **6.5/10** | ⚠️ Docker overhead | ⭐⭐⭐⭐ Complex | ⭐⭐⭐⭐ Excellent | **❌ NOT RECOMMENDED** |
| **memsearch** | Milvus-based hybrid vector + BM25 retrieval, Markdown logs, Git support | N/A | **6.0/10** | ⚠️ Heavy | ⭐⭐⭐⭐ Complex | ⭐⭐⭐ Good | **❌ NOT RECOMMENDED** |
| **LlamaIndex + ChromaDB** | RAG framework combining markdown parsing with vector database for semantic search | N/A | **6.5/10** | ⚠️ Moderate | ⭐⭐⭐ Medium | ⭐⭐⭐ Good | **⚠️ CONDITIONAL** |
| **Qdrant** | High-performance vector database for production-scale semantic search | N/A | **5.0/10** | ⚠️ Overkill | ⭐⭐⭐⭐ Complex | ⭐⭐⭐⭐ Excellent | **❌ NOT RECOMMENDED** |
| **Weaviate** | Enterprise vector database with advanced ML integration and complex filtering | N/A | **4.5/10** | ⚠️ Overkill | ⭐⭐⭐⭐ Complex | ⭐⭐⭐⭐ Excellent | **❌ NOT RECOMMENDED** |
| **Neo4j GraphRAG** | Knowledge graph construction from markdown with entity extraction and relationship mapping | N/A | **6.0/10** | ⚠️ Heavy | ⭐⭐⭐⭐ Complex | ⭐⭐⭐ Good | **❌ NOT RECOMMENDED** |

---

## Detailed Solution Analysis

### 🥇 gnosis-mcp (RECOMMENDED)

**Repository:** [nicholasglazer/gnosis-mcp](https://github.com/nicholasglazer/gnosis-mcp)
**Website:** https://gnosismcp.com/

#### Key Features
- ✅ **Zero-config setup** - Install and run
- ✅ **Semantic search** - Find docs by meaning, not just keywords
- ✅ **Local ONNX embeddings** - No API keys required
- ✅ **SQLite default** - Lightweight for N100
- ✅ **Git history indexing** - Tracks documentation evolution
- ✅ **5-10× token reduction** - Optimizes context loading
- ✅ **MCP native** - Drop-in for Claude Code

#### Setup (5 minutes)
```bash
# Install
pip install 'gnosis-mcp[onnx]'

# Configure Claude Code (~2 minutes)
# Edit ~/.claude/settings.json:
{
  "mcpServers": {
    "gnosis": {
      "command": "gnosis-mcp",
      "args": ["--directory", "/home/macryba/testdziej-questions"]
    }
  }
}

# Index both docs and history-data
gnosis-mcp --directory docs/ --directory history-data/
```

#### For Your Use Case
**Docs folder (44 files):**
- Query: "How do I set up local development?"
- Returns: `env/local-dev/QUICKSTART.md` + relevant context
- Tokens: ~500 (vs 5000+ without gnosis-mcp)

**Quiz files (241 files):**
- Query: "Find questions about Polish battles"
- Returns: Relevant quiz files across all epochs
- Semantic understanding finds related topics automatically

#### Pros
- Zero maintenance
- Best token efficiency
- Lightest hardware usage
- Git history support
- No API dependencies

#### Cons
- Newer project (less mature than basic-memory)
- No knowledge graph features
- Limited community compared to larger projects

#### Confidence Score: 9.0/10

---

### 🥈 basic-memory

**Repository:** [basicmachines-co/basic-memory](https://github.com/basicmachines-co/basic-memory)
**Documentation:** https://docs.basicmemory.com/

#### Key Features
- ✅ **Semantic vector search** (v0.19.0)
- ✅ **Knowledge graph navigation** - Wiki-link traversal
- ✅ **Bi-directional editing** - AI can write notes
- ✅ **MCP native** - 15+ tools for agents
- ✅ **Local-first** - SQLite indexing
- ✅ **Mature project** - Regular updates

#### Setup (~1 hour)
```bash
# Install
uv tool install basic-memory

# Configure Claude Code
{
  "mcpServers": {
    "basic-memory": {
      "command": "uvx",
      "args": ["basic-memory", "mcp"]
    }
  }
}

# Index files
basic-memory sync
```

#### For Your Use Case
**Docs folder:**
- Build context from wiki-links: `[[env/local-dev/QUICKSTART]]`
- Traverse relationships automatically
- AI can add new observations

**Quiz files:**
- Semantic search finds similar questions
- "Questions about Grunwald" → finds related Jagiellonowie questions
- Knowledge graph connects historical topics

#### Pros
- Knowledge graph features
- Mature and actively developed
- Rich toolset for agents
- Bi-directional knowledge building

#### Cons
- More complex setup than gnosis-mcp
- Heavier resource usage
- Overkill if you only need search
- Requires learning file format conventions

#### Confidence Score: 8.5/10

---

### 🥉 Simple Index File

**Purpose:** Immediate, zero-dependency solution

#### Setup (10 minutes)
Create `docs/INDEX.md`:
```markdown
# Documentation Index

## Quick Start
- [[env/local-dev/QUICKSTART]] - Local development setup
- [[specs/AI_AGENT_QUICK_START]] - AI agent quick start

## By Task
### Question Generation
- [[.claude/instructions.md]] - Complete workflow (read first!)
- [[.claude/validation-rules.md]] - Answer validation rules
- [[specs/chapters.md]] - Chapter structure

### Environment Setup
- [[env/local-dev/QUICKSTART]] - Local setup
- [[env/DEVOPS_QUICK_START.md]] - DevOps setup
- [[env/ENVIRONMENT_MANAGEMENT.md]] - Environment management

### Standards
- [[standards/react-native.md]] - React Native standards
- [[specs/error-handling.md]] - Error handling
```

#### Pros
- ✅ Zero dependencies
- ✅ Works instantly
- ✅ Agent reads index, loads only relevant files
- ✅ Uses existing wiki-link style
- ✅ Perfect for N100 hardware

#### Cons
- ❌ No semantic search
- ❌ Manual maintenance required
- ❌ Limited to direct lookups

#### Confidence Score: 9.0/10 (for simplicity), 6.0/10 (for features)

---

### MCP-Markdown-RAG

**Repository:** [Zackriya-Solutions/MCP-Markdown-RAG](https://github.com/Zackriya-Solutions/MCP-Markdown-RAG)

#### Key Features
- Purpose-built for markdown files
- Recursive subdirectory indexing
- File-based Milvus (no server process)
- Semantic search

#### Pros
- Simple setup
- Designed exactly for this use case
- No knowledge graph complexity

#### Cons
- Less mature than basic-memory
- Limited documentation

#### Confidence Score: 8.0/10

---

### mcp-local-rag

**Repository:** [shinpr/mcp-local-rag](https://github.com/shinpr/mcp-local-rag)

#### Key Features
- Semantic + keyword-boost search
- LanceDB (no server process)
- Privacy-focused

#### Pros
- No server process (ideal for N100)
- Lightweight
- Good for code and technical docs

#### Cons
- Less mature
- Smaller community

#### Confidence Score: 7.5/10

---

### dotMD

**Repository:** [inventivepotter/dotmd](https://github.com/inventivepotter/dotmd)

#### Key Features
- Hybrid search: semantic + BM25 + knowledge graph
- Cross-encoder reranking
- Zero API costs
- MCP server

#### Pros
- No API costs
- Good feature set
- Local-only

#### Cons
- Medium setup complexity
- Smaller project

#### Confidence Score: 8.0/10

---

### QMD (Query Markdown)

**Repository:** [ehc-io/qmd](https://github.com/ehc-io/qmd)

#### Key Features
- BM25 + vector + LLM rerank
- 95% token reduction
- Containerized
- Hybrid search

#### Pros
- Excellent token efficiency
- LLM reranking improves accuracy
- Hybrid search approach

#### Cons
- **Requires OpenRouter API key** (external dependency)
- Containerized (Docker overhead on N100)

#### Confidence Score: 7.0/10

---

### vault-mcp

**MCP Marketplace:** https://mcpmarket.com/server/vault-mcp

#### Key Features
- RAG over standard .md vaults
- Live file-sync
- Quality-scored chunking
- REST + MCP endpoints

#### Pros
- Live sync useful for docs folder
- Good chunking strategy

#### Cons
- Ensure file-sync doesn't overwhelm N100

#### Confidence Score: 7.0/10

---

### Solutions NOT Recommended for N100/16GB

#### ❌ DuckDB Hybrid Doc Search
- **Issue:** Docker overhead too much for N100
- **Score:** 6.5/10

#### ❌ memsearch
- **Issue:** Milvus too heavy for N100
- **Score:** 6.0/10

#### ❌ Neo4j GraphRAG
- **Issue:** Way too resource-intensive
- **Score:** 6.0/10

#### ❌ IWE (Interwoven Wiki Engine)
- **Issue:** Steep learning curve for limited benefit
- **Score:** 6.5/10

#### ❌ Qdrant / Weaviate
- **Issue:** Overkill for 285 markdown files
- **Score:** 5.0/10 and 4.5/10

---

## Hardware-Specific Recommendations

### ✅ SAFE for N100/16GB

1. **gnosis-mcp** - SQLite + ONNX (lightest)
2. **Simple Index File** - Zero overhead
3. **MCP-Markdown-RAG** - File-based Milvus
4. **mcp-local-rag** - LanceDB (embedded)
5. **basic-memory** - SQLite (acceptable)
6. **dotMD** - Local-only

### ⚠️ USE WITH CAUTION

1. **QMD** - Great but needs OpenRouter API (external dependency)
2. **vault-mcp** - Good but ensure file-sync doesn't overwhelm N100

### ❌ AVOID on N100

1. **DuckDB Hybrid** - Docker overhead
2. **memsearch** - Milvus too heavy
3. **Neo4j GraphRAG** - Resource-intensive
4. **IWE** - Complex for limited benefit
5. **Qdrant / Weaviate** - Overkill

---

## Implementation Roadmap

### Phase 1: Immediate (Today - 10 minutes)

**Option A: Simple Index File**
```bash
# Create docs/INDEX.md with wiki-links
# Agent reads index, loads relevant files
# Zero dependencies, works instantly
```

### Phase 2: This Week (1 hour)

**Option B: Install gnosis-mcp**
```bash
# Install (5 minutes)
pip install 'gnosis-mcp[onnx]'

# Configure Claude Code (2 minutes)
# Edit ~/.claude/settings.json

# Test both use cases (30 minutes)
# - Docs folder query
# - Quiz files query

# Evaluate (rest of week)
# - Monitor token usage
# - Check search quality
```

### Phase 3: Long-term Decision (2 weeks)

**Evaluation Criteria:**
- Token usage reduction
- Search quality/relevance
- Maintenance overhead
- Hardware performance

**Decision Tree:**
```
Is gnosis-mcp working well?
├─ YES → Stay with gnosis-mcp (zero maintenance)
└─ NO → Need knowledge graph?
    ├─ YES → Switch to basic-memory
    └─ NO → Stay with index file or MCP-Markdown-RAG
```

---

## Use Case Examples

### Example 1: Question Generation Task

**Query:** "How do I generate questions for the Piastowie epoch?"

**With Simple Index:**
```
1. Agent reads docs/INDEX.md
2. Finds link to .claude/instructions.md
3. Loads only that file
4. Tokens: ~2000
```

**With gnosis-mcp:**
```
1. Agent queries: "question generation Piastowie"
2. gnosis-mcp semantic search
3. Returns: .claude/instructions.md + relevant validation rules
4. Tokens: ~800 (5× reduction)
```

**With basic-memory:**
```
1. Agent queries: "question generation"
2. basic-memory builds context
3. Returns: instructions + validation rules + chapter summaries
4. Tokens: ~1500 (3× reduction)
```

### Example 2: Finding Similar Questions

**Query:** "Find questions about Polish battles"

**With Simple Index:**
```
❌ Can't do semantic search
❌ Would need manual categorization
```

**With gnosis-mcp:**
```
✅ Semantic search finds:
   - Battle of Grunwald (Jagiellonowie)
   - Battle of Vienna (03-rozbiory)
   - Battle of Lenino (08-prl)
✅ Finds across all epochs by meaning
✅ Tokens: ~1200 (relevant questions only)
```

**With basic-memory:**
```
✅ Knowledge graph navigation:
   - "battles" → related topics → linked questions
✅ Finds connections between historical events
✅ Tokens: ~2000 (includes context)
```

### Example 3: Documentation Troubleshooting

**Query:** "How do I reset the staging database?"

**With gnosis-mcp:**
```
Query: "reset staging database"
Returns: env/staging/reset-db.md + related setup docs
Tokens: ~600
```

**With basic-memory:**
```
Query: "reset database staging"
build_context follows:
[[env/staging/reset-db.md]] → [[env/ENVIRONMENT_MANAGEMENT.md]]
Tokens: ~1000 (includes related context)
```

---

## Comparison Summary

| Use Case | Best Tool | Why |
|----------|-----------|-----|
| **Semantic search + token efficiency** | 🥇 gnosis-mcp | 5-10× reduction, zero-config |
| **Knowledge graph + relationships** | 🥇 basic-memory | Wiki-link traversal, bi-directional |
| **Purpose-built markdown indexing** | 🥇 MCP-Markdown-RAG | Designed exactly for this |
| **Zero dependencies, instant** | 🥇 Simple Index File | Works in 10 minutes |
| **Lightest hardware usage** | 🥇 gnosis-mcp | ONNX + SQLite |
| **Git history tracking** | 🥇 gnosis-mcp | Unique feature |
| **Mature + stable** | 🥇 basic-memory | More established |

---

## Final Recommendation

### For Your Specific Requirements:

**🥇 TOP CHOICE: gnosis-mcp**

**Rationale:**
1. ✅ Zero-config (solves "no manual routing")
2. ✅ 5-10× token reduction (solves "context optimization")
3. ✅ Semantic search (finds relevant docs/questions by meaning)
4. ✅ Perfect for N100/16GB (lightweight SQLite + ONNX)
5. ✅ Dual-purpose ready (docs + quiz files)
6. ✅ Git history support (tracks documentation evolution)
7. ✅ MCP native (drop-in for Claude Code)

**🥈 BACKUP: basic-memory**

**Choose if you need:**
- Knowledge graph features
- Wiki-link traversal
- Bi-directional editing (AI writes notes)
- More mature project

**🥉 FALLBACK: Simple Index File**

**Choose if:**
- You need something working in 10 minutes
- Semantic search isn't critical
- You want zero dependencies

---

## Maintenance Notes

### Updating This Document

When evaluating new solutions or updating recommendations:
1. Update the comparison table
2. Add new solutions as they emerge
3. Update confidence scores based on testing
4. Document your experiences in "Implementation Notes" section below

### Implementation Notes

*(Add your notes here as you test solutions)*

**gnosis-mcp Testing:**
- Date installed:
- Token usage observations:
- Search quality:
- Issues encountered:

**basic-memory Testing:**
- Date installed:
- Knowledge graph usefulness:
- Resource usage:
- Issues encountered:

---

## Sources and References

### MCP Servers
- [gnosis-mcp GitHub](https://github.com/nicholasglazer/gnosis-mcp)
- [gnosis-mcp Official Site](https://gnosismcp.com/)
- [basic-memory GitHub](https://github.com/basicmachines-co/basic-memory)
- [basic-memory Documentation](https://docs.basicmemory.com/)
- [MCP-Markdown-RAG GitHub](https://github.com/Zackriya-Solutions/MCP-Markdown-RAG)
- [mcp-local-rag GitHub](https://github.com/shinpr/mcp-local-rag)
- [QMD GitHub](https://github.com/ehc-io/qmd)
- [dotMD Reddit Discussion](https://www.reddit.com/r/ClaudeCode/comments/1qsdsz6/dotmd_local_hybrid_search_for_markdown_files/)
- [vault-mcp on MCP Marketplace](https://mcpmarket.com/server/vault-mcp)

### Python Libraries
- [LlamaIndex Documentation](https://developers.llamaindex.ai/)
- [memsearch GitHub](https://github.com/zilliztech/memsearch)
- [memsearch Milvus Blog](https://milvus.io/blog/we-extracted-openclaws-memory-system-and-opensourced-it-memsearch.md)

### Knowledge Graph
- [IWE LinkedIn Post](https://www.linkedin.com/posts/steve-hedden_open-knowledge-graphs-a-search-engine-for-activity-7439309770525831168-8Ab_)
- [GitNexus GitHub](https://github.com/abhigyanpatwari/GitNexus)

### Vector Databases
- [Qdrant Documentation](https://qdrant.tech/)
- [Weaviate Documentation](https://weaviate.io/)
- [ChromaDB Documentation](https://docs.trychroma.com/)

### Research Articles
- [What Is the LLM Knowledge Base Index File?](https://www.mindstudio.ai/blog/llm-knowledge-base-index-file-no-vector-search/)
- [Markdown as a Knowledge Base for AI Agents - LinkedIn](https://www.linkedin.com/pulse/markdown-knowledge-base-ai-agents-practical-rag-andrea-bonadonna-zaamf)
- [In Agentic AI, It's All About the Markdown - Visual Studio Magazine](https://visualstudiomagazine.com/articles/2026/02/24/in-agentic-ai-its-all-about-the-markdown.aspx)
- [The simplest way to build AI agents in 2026](https://newsletter.owainlewis.com/p/the-simplest-way-to-build-ai-agents)
- [Top Open-Source Vector Databases Comparison](https://blog.octabyte.io/topics/open-source-databases/vector-databases-comparison/)
- [Context Layer for AI Agents - Firecrawl Blog](https://www.firecrawl.dev/blog/context-layer-for-ai-agents)
- [Agentic Knowledge Graph Construction with Neo4j](https://shilpathota.medium.com/agentic-knowledge-graph-construction-with-neo4j-aadda43b71d9)
- [Semantic GraphRAG Implementation Guide](https://medium.com/@visrow/semantic-graphrag-implementation-guide-build-real-world-ai-knowledge-systems-with-neo4j-qdrant-9d272d2f99c4)

### Tools
- [markymark GitHub](https://github.com/sethyanow/markymark)
- [markdown_query GitHub](https://github.com/ssosik/markdown_query)
- [markdown-indexer GitHub](https://github.com/cagatayuresin/markdown-indexer)
- [Obsidian Graph Documentation](https://obsidian.md/help/plugins/graph)

---

## Appendix: File Structure

### Current Documentation Structure
```
docs/
├── content.md
├── development/
│   └── database-seeding.md
├── env/
│   ├── branching-strategy.md
│   ├── DEVOPS_QUICK_START.md
│   ├── DEVOPS_SETUP.md
│   ├── ENVIRONMENT_MANAGEMENT.md
│   ├── local-dev/
│   │   ├── android-local-builds.md
│   │   ├── docker.md
│   │   ├── QUICKSTART.md
│   │   ├── README.md
│   │   ├── reset-db.md
│   │   ├── web-e2e-test.md
│   │   └── web-only-setup.md
│   ├── production/
│   ├── staging/
│   │   ├── mini-pc-staging.md
│   │   ├── README.md
│   │   ├── reset-db.md
│   │   ├── reset.md
│   │   └── staging-setup.md
│   └── testing-env.md
├── product/
│   ├── F-001-guest-mode.md
│   ├── F-026-reviewer-dashboard.md
│   ├── feature-template.md
│   └── README.md
├── prototypes/
├── specs/
│   ├── ai-agent-development-guide.md
│   ├── AI_AGENT_QUICK_START.md
│   ├── brand.md
│   ├── chapters.md
│   ├── claude-code-testing-subagent-strategy.md
│   ├── e2e-tests.md
│   ├── error-handling.md
│   ├── evaluation.md
│   ├── flagging_questions.md
│   ├── idea.md
│   ├── implementation-dependency-map.md
│   ├── managing-users.md
│   ├── testdziej-specs.md
│   └── test-strategy.md
├── standards/
│   ├── react-native-audit-1.md
│   ├── react-native.md
│   └── ui-components.md
├── sync/
│   └── QUESTION_SYNC_WORKFLOW.md
├── test-plans/
│   └── AUTHENTICATION.md
├── troubleshooting/
│   └── missing-profiles.md
├── ui-components.md
└── docs_indexing.md (this file)
```

### Current Quiz Files Structure
```
history-data/
├── 01-starozytnosc/
│   ├── 01-pradzieje/
│   ├── 02-slowianie/
│   └── ...
├── 02-piastowie/
│   ├── 01-chrystianizacja/
│   ├── 02-boleslaw-chrobry/
│   └── ...
├── 03-jagiellonowie/
├── 04-rzeczpospolita/
├── 05-rozbiory/
├── 06-miedzywojnie/
├── 07-ii-wojna-swiatowa/
├── 08-prl/
└── 09-iii-rp/
```

**Total files:** 285 markdown files (44 docs + 241 quiz files)

---

**Document Version:** 1.0
**Last Updated:** 2026-05-09
**Next Review:** 2026-05-23 (2 weeks)
