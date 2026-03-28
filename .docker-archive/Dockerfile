FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    postgresql-client \
    python3 \
    python3-pip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Claude CLI
RUN curl -fsSL https://claude.ai/install.sh | sh

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . /workspace/

# Set environment
ENV CLAUDE_WORKSPACE=/workspace
ENV CLAUDE_STATE_FILE=/workspace/.claude/state.json

# Entry point
ENTRYPOINT ["/workspace/scripts/loop-controller.sh"]