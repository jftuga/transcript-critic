#!/usr/bin/env bash

# Installs the transcript-critic skill for Claude Code:
# 1. Copies SKILL.md to ~/.claude/skills/transcribe/
# 2. Adds permission rules to ~/.claude/settings.json so that
#    /transcribe runs without interactive prompts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="${HOME}/.claude/skills/transcribe"
SETTINGS_FILE="${HOME}/.claude/settings.json"

# --- 1. Install the skill ---
mkdir -p "$SKILL_DIR"
cp -f "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
echo "Installed SKILL.md to $SKILL_DIR/"

# --- 2. Add permissions to global settings ---
# Allow reading the analysis prompt and other files from this repository.
# Because /transcribe is a global skill that runs from any directory,
# this rule must be in the global ~/.claude/settings.json.

READ_RULE="Read(~/github.com/jftuga/transcript-critic/**)"

python3 "$SCRIPT_DIR/add_permission.py" "$SETTINGS_FILE" "$READ_RULE"

echo ""
echo "Installation complete. You can now use /transcribe in Claude Code."
