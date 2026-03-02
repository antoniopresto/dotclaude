#!/bin/bash

# Claude Code SessionStart Hook
# Injects current date/time to prevent year confusion from training data

CURRENT_DATE=$(date '+%Y-%m-%d')
CURRENT_TIME=$(date '+%H:%M:%S')
CURRENT_DATETIME=$(date '+%Y-%m-%d %H:%M:%S %Z')
DAY_OF_WEEK=$(date '+%A')
TIMEZONE=$(date '+%Z (%z)')
YEAR=$(date '+%Y')

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "[SYSTEM TIME SYNC] Today is ${DAY_OF_WEEK}, ${CURRENT_DATE}. Current time: ${CURRENT_TIME} ${TIMEZONE}. Year: ${YEAR}. Use this as the authoritative date/time reference, NOT training data assumptions."
  }
}
EOF

exit 0
