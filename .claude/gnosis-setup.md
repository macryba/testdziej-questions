# Gnosis MCP Setup

## Overview
Gnosis MCP is installed and configured to provide semantic search across all historical quiz questions and documentation in the `history-data/` folder.

## Installation Details
- **Package:** gnosis-mcp[embeddings]
- **Installation method:** `uv tool install gnosis-mcp[embeddings]`
- **Executable location:** `/home/macryba/.local/bin/gnosis-mcp`
- **Database:** `.gnosis-data/gnosis.db` (15MB SQLite)
- **Embedding model:** MongoDB/mdbr-leaf-ir (local ONNX, 384 dimensions)

## Index Statistics
- **Documents indexed:** 244 files
- **Total chunks:** 2,183
- **Embedded chunks:** 2,183 (100%)
- **Content size:** 2.0 MB

## MCP Configuration
Located in `.mcp.json`:
```json
{
  "mcpServers": {
    "gnosis": {
      "type": "stdio",
      "command": "/home/macryba/.local/bin/gnosis-mcp",
      "args": ["serve"],
      "env": {
        "GNOSIS_MCP_DATABASE_URL": ".gnosis-data/gnosis.db",
        "GNOSIS_MCP_EMBED_PROVIDER": "local",
        "GNOSIS_MCP_WRITABLE": "true"
      }
    }
  }
}
```

## Available Tools
- `search_docs` - Hybrid semantic + keyword search
- `get_doc` - Retrieve full document by path
- `get_related` - Find linked/related documents
- `get_context` - Usage-weighted context summary
- `get_graph_stats` - Knowledge graph topology
- `upsert_doc` - Create or replace documents
- `delete_doc` - Remove documents
- `update_metadata` - Change metadata

## Usage Examples

### Direct CLI usage:
```bash
# Keyword search
gnosis-mcp search "Piastowie Chrystianizacja" --embed -n 5

# Check statistics
gnosis-mcp stats

# Re-index after adding new questions
gnosis-mcp ingest history-data/ --embed --force
```

### Via MCP (in Claude Code):
The AI assistant can automatically search the indexed historical data when answering questions about:
- Specific historical epochs (Piastowie, Rzeczpospolita Obojga Narodów, etc.)
- Chapters and topics
- Question difficulty levels
- Sources and references

## Re-indexing
When new questions are added to `history-data/`, re-run:
```bash
gnosis-mcp ingest history-data/ --embed
```

Or use `--force` to re-index all files:
```bash
gnosis-mcp ingest history-data/ --embed --force
```

## Technical Details
- **Backend:** SQLite with FTS5 (keyword) + sqlite-vec (semantic)
- **Search type:** Hybrid (Reciprocal Rank Fusion)
- **Embeddings:** Local ONNX model (no API key needed)
- **Chunking:** Smart H2/H3 heading-based splitting
- **Permissions:** Configured in `.claude/settings.local.json`

## Git Configuration
The `.gnosis-data/` directory is excluded from git via `.gitignore` to prevent committing the database file.
