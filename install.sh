#!/usr/bin/env bash

# Installs the transcript-critic skill for Claude Code:
# 1. Copies SKILL.md, transcribe.sh and ANALYSIS_PROMPT.md to
#    ~/.claude/skills/transcribe/, so the skill works no matter where this
#    repository was cloned.
# 2. Adds permission rules to ~/.claude/settings.json so that
#    /transcribe runs without interactive prompts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="${HOME}/.claude/skills/transcribe"
SETTINGS_FILE="${HOME}/.claude/settings.json"

# --- 1. Install the skill ---
mkdir -p "$SKILL_DIR"
cp -f "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
cp -f "$SCRIPT_DIR/ANALYSIS_PROMPT.md" "$SKILL_DIR/ANALYSIS_PROMPT.md"
cp -f "$SCRIPT_DIR/transcribe.sh" "$SKILL_DIR/transcribe.sh"
chmod +x "$SKILL_DIR/transcribe.sh"
echo "Installed SKILL.md, ANALYSIS_PROMPT.md and transcribe.sh to $SKILL_DIR/"

# --- 2. Add permissions to global settings ---
# Because /transcribe is a global skill that runs from any directory,
# these rules must be in the global ~/.claude/settings.json.
#   - Read: lets Claude read ANALYSIS_PROMPT.md without prompting.
#   - Bash: lets Claude run transcribe.sh without prompting.

READ_RULE="Read(~/.claude/skills/transcribe/**)"
BASH_RULE="Bash(~/.claude/skills/transcribe/transcribe.sh:*)"

# Find a working Python 3. On Windows, "python3" is often only a Microsoft
# Store placeholder, so also try "python" and the "py" launcher.
PYTHON=()
for candidate in "python3" "python" "py -3"; do
    read -r -a cmd <<< "$candidate"
    if command -v "${cmd[0]}" >/dev/null 2>&1 \
        && "${cmd[@]}" -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)' >/dev/null 2>&1; then
        PYTHON=("${cmd[@]}")
        break
    fi
done
if [[ ${#PYTHON[@]} -eq 0 ]]; then
    echo "Error: Python 3 not found (tried python3, python, py -3)." >&2
    exit 1
fi

"${PYTHON[@]}" "$SCRIPT_DIR/add_permission.py" "$SETTINGS_FILE" "$READ_RULE" "$BASH_RULE"

echo ""
echo "Installation complete. You can now use /transcribe in Claude Code."
echo "Re-run this script after pulling updates to refresh the installed files."
