# Secret environment variables — loaded via `op inject`
# This file is safe to commit: it contains only 1Password references.
# Actual values are resolved at runtime by `op inject`.
#
# Setup: brew install --cask 1password-cli
# Auth:  op signin
# Test:  op inject -i ~/.secrets.tpl

# ── Git ─────────────────────────────────
git config --global user.name "{{ op://Employee/Git Config/name }}"
git config --global user.email "{{ op://Employee/Git Config/email }}"
git config --global user.signingkey "{{ op://Employee/Git Config/signingkey }}"
git config --global commit.gpgsign true

# ── AI / LLM API Keys ──────────────────
# OPENAI_API_KEY / ANTHROPIC_API_KEY deliberately absent: Claude Code and
# Codex run on subscription auth, and an exported key silently flips headless
# CLI calls (claude -p, codex exec) to pay-per-token API billing. The one
# remaining consumer (codecompanion inline edits) reads the Anthropic key
# on demand via `op read` in its adapter config instead.
export GOOGLE_API_KEY="{{ op://Employee/Google API Key/credential }}"
export OPENROUTER_API_KEY="{{ op://Employee/OpenRouter API Key/credential }}"
export CONTEXT7_API_KEY="{{ op://Employee/Context7 API Key/credential }}"
