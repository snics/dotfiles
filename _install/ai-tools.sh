#!/usr/bin/env bash

echo -e "Installing AI CLI tools..."

# Gemini CLI (Google) — requires Node.js 18+
# https://github.com/google-gemini/gemini-cli
if ! command -v gemini &> /dev/null; then
  echo "Installing Gemini CLI..."
  npm install -g @google/gemini-cli
else
  echo "Gemini CLI already installed ($(gemini --version))"
fi

# Codex CLI (OpenAI) — requires Node.js
# https://github.com/openai/codex
if ! command -v codex &> /dev/null; then
  echo "Installing Codex CLI..."
  npm install -g @openai/codex
else
  echo "Codex CLI already installed ($(codex --version))"
fi

echo -e "AI CLI tools installation done!"
echo -e ""
echo -e "Note: The following tools are installed via Brewfile:"
echo -e "  - claude-code (cask)"
echo -e "  - opencode (brew sst/tap/opencode)"
echo -e ""
echo -e "Run 'gemini' and 'codex' to authenticate on first use."
