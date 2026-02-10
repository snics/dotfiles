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
export OPENAI_API_KEY="{{ op://Employee/OpenAI API Key/credential }}"
export ANTHROPIC_API_KEY="{{ op://Employee/Anthropic API Key/credential }}"
export GOOGLE_API_KEY="{{ op://Employee/Google API Key/credential }}"
export OPENROUTER_API_KEY="{{ op://Employee/OpenRouter API Key/credential }}"
export CONTEXT7_API_KEY="{{ op://Employee/Context7 API Key/credential }}"
