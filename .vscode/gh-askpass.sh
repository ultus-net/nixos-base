#!/usr/bin/env bash
# Minimal askpass helper that returns GitHub username/password (token)
# Uses the GitHub CLI which must be installed and authenticated in the
# environment. This prevents the system SSH askpass GUI from appearing
# and allows non-interactive pushes from VS Code when using HTTPS.

prompt="$*"

case "$prompt" in
  *Username* )
    gh api user --jq .login 2>/dev/null || echo "$(git config user.name || true)" || true
    ;;
  *Password* )
    gh auth token 2>/dev/null || exit 1
    ;;
  * )
    # default to outputting token
    gh auth token 2>/dev/null || exit 1
    ;;
esac
