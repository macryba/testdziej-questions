# Docker Files Archive

This directory contains Docker-related files that are no longer in use.

## Reason for Archival

The project was originally designed to run the Claude Code loop inside a Docker container. During setup, it was decided to run the loop directly on the host OS instead for simplicity.

## Files

- `Dockerfile` - Ubuntu 24.04 container with Claude CLI installed
- `docker-compose.yml` - Container orchestration configuration

## Current Approach

The loop now runs directly on the host OS:
1. Initial setup: `source claude_code_zai_env.sh`
2. Run loop: `claude` (follow `.claude/instructions.md`)

See `CLAUDE.md` for updated instructions.
